module ThreadKit
  module ThreadLocal
    module Accessors
      def self.included(base)
        base.extend(ClassMethods)
      end

      def self.extended(base)
        fail "#{self.name} is not meant to be extended. use include instead"
      end

      module ClassMethods
        # thread local attr_accessor
        def tl_attr_accessor(*method_names, default: nil)
          tl_attr_reader(*method_names, default: default)
          tl_attr_writer(*method_names)
        end

        # thread local attr_reader
        def tl_attr_reader(*attrs, default: nil)
          attrs.each do |attribute|
            define_method(attribute) do
              Store.get(self, attribute, default: default)
            end
          end
        end

        # thread local attr_writer
        def tl_attr_writer(*attrs)
          attrs.each do |attribute|
            method_name = "#{attribute}=".to_sym
            define_method(method_name) do |new_value|
              Store.set(self, attribute, new_value)
            end
          end
        end
      end
    end
  end
end