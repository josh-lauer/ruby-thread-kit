module ThreadKit
  class Finalizer
    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :register
    end

    def register(obj, &action)
      ObjectSpace.define_finalizer(obj) do |obj_id|
        finalize_id!(obj_id, &action)
      end
    end

    private

    def finalize_id!(obj_id, &action)
      action.call(obj_id)
    end
  end
end
