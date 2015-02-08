module ThreadKit
  module ThreadLocal
    class Store
      @singleton_lock = Mutex.new
      private_class_method :new
      attr_reader :store, :thread_init_lock

      class << self
        extend Forwardable
        def_delegators :instance, :set, :get

        # synchronize creating the global instance with a lock attached to ThreadKit::ThreadLocal::Store
        def instance
          @instance || @singleton_lock.synchronize { @instance = new }
        end
      end

      def initialize
        # {
        #   123456 => {          # Thread.current.object_id
        #     7890123 => {       # object_id of an object instance
        #       foo: 'bar'       # an 'ivar' local to thread 123456 on object 7890123 called :foo
        #     }  
        #   }
        # }
        @store = {}

        # a lock for creating new threads
        @thread_init_lock = Monitor.new
      end

      # fetch the value for the given key in the current thread relative to the given object
      def set(obj, key, val)
        thr_id = Thread.current.__id__
        thread_store = store[thr_id]
        if thread_store
          (thread_store[obj.__id__] ||= {})[key.to_sym] = val
        else
          thread_init_lock.synchronize do
            unless store.key?(thr_id)
              store[thr_id] = { obj.__id__ => { key.to_sym => val } }
            end
          end
        end
        val
      end

      # fetch the value for the given key in the current thread relative to the given object
      def get(obj, key, default: nil)
        if default.nil?
          read_object_hash(obj)[key.to_sym]
        else
          object_hash = read_object_hash(obj)
          object_hash.key?(key.to_sym) ? object_hash[key.to_sym] : default
        end
      end

      # is the given key set on the given object?
      def key?(obj, key)
        read_object_hash(obj).key?(key.to_sym)
      end

      private

      def read_object_hash(obj)
        (thr_hash = store[Thread.current.__id__]) && (obj_hash = thr_hash[obj.__id__]) || {}
      end

      def define_object_finalizer(obj)
        # delete thread locals for this object from all threads when it is deconstructed
        ObjectSpace.define_finalizer(obj) do |obj_id|
          finalize_object!(obj_id)
        end
      end

      def finalize_object!(obj_id)
        puts "FINALIZING OBJECT #{obj_id}"
        store.each_pair { |_, objects| objects.delete(obj_id) }
      end

      def define_thread_finalizer(thread)
        ObjectSpace.define_finalizer(thread) do |obj_id|
          finalize_thread!(obj_id)
        end
      end

      # delete all thread locals for this thread when it is deconstructed
      def finalize_thread!(obj_id)
        puts "FINALIZING THREAD #{obj_id}"
        store.delete(obj_id)
      end
    end
  end
end