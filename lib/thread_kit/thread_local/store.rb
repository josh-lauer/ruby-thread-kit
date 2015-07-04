require 'singleton'
require 'forwardable'

module ThreadKit
  module ThreadLocal
    class Store
      include Singleton

      class << self
        extend Forwardable
        def_delegators :instance, :set, :get
      end

      # fetch the value for the given key in the current thread relative to the given object
      def set(obj, key, val, **options)
        register_finalizer(obj)
        object_store(obj)[key.to_sym] = val
      end

      # fetch the value for the given :key associated with :obj in Thread.current
      # relative to the given :obj
      def get(obj, key, **options)
        object_store(obj)[key.to_sym]
      end

      # check if there is a value stored with :key relative to :obj
      def object_has_key?(obj, key)
        object_initialized?(obj) && object_store(obj).key?(key.to_sym)
      end

      # check if there are any values stored on the given object in the current thread
      def object_initialized?(obj)
        thread_store.key?(obj.__id__)
      end

      private

      # define a finalizer for the given object unless one has already been defined for
      # this object in the current thread
      def register_finalizer(obj)
        ObjectSpace.define_finalizer(obj, &method(:flush_object)) unless object_initialized?(obj)
      end

      # delete storage for the specified obj_id on the current thread
      def flush_object(obj_id)
        thread_store.delete(obj_id)
      end

      # returns the hash of values stored for :obj
      def object_store(obj)
        thread_store[obj.__id__]
      end

      # returns a hash
      def thread_store
        Thread.current[root_key] ||= Hash.new { |h,k| h[k] = {} }
      end

      def root_key
        :__threadkit_local_store__
      end
    end
  end
end
