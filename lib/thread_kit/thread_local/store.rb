module ThreadKit
  module ThreadLocal
    class Store
      include Singleton

      class << self
        extend Forwardable
        def_delegators :instance, :set, :get, :key?
      end

      # fetch the value for the given key in the current thread relative to the given object
      def set(obj, key, val)
        object_store(obj)[key.to_s] = val
      end

      # fetch the value for the given key in the current thread relative to the given object
      def get(obj, key)
        object_store(obj)[key.to_s]
      end

      # is the given key set on the given object?
      def key?(obj, key)
        object_store(obj).key?(key)
      end

      private

      def object_store(obj)
        thread_store[obj.__id__]
      end

      def thread_store
        Thread.current[root_key] ||= Hash.new { |h,k| h[k] = {} }
      end

      def root_key
        :__thread_local_ivar_store__
      end

      ############################
      #### garbage collection ####
      ############################

      # def define_object_finalizer(obj)
      #   # delete thread locals for this object from all threads when it is deconstructed
      #   ObjectSpace.define_finalizer(obj) do |obj_id|
      #     finalize_object!(obj_id)
      #   end
      # end

      # def finalize_object!(obj_id)
      #   store.each_pair { |_, objects| objects.delete(obj_id) }
      # end

      # def define_thread_finalizer(thread)
      #   ObjectSpace.define_finalizer(thread) do |obj_id|
      #     finalize_thread!(obj_id)
      #   end
      # end

      # # delete all thread locals for this thread when it is deconstructed
      # def finalize_thread!(obj_id)
      #   store.delete(obj_id)
      # end
    end
  end
end