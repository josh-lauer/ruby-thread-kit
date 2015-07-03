module ThreadKit
  module ThreadLocal
    module Accessors
      # thread local attr_accessor
      def tl_attr_accessor(*attrs, default: nil)
        tl_attr_reader(*attrs, default: default)
        tl_attr_writer(*attrs)
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

      def tl_cattr_accessor(*attrs, default: nil)
        tl_cattr_reader(*attrs, default: default)
        tl_cattr_writer(*attrs)
      end

      def tl_cattr_reader(*attrs, default: nil)
        attrs.each do |attribute|
          define_method(attribute) do
            Store.get(self.class, attribute, default: default)
          end

          define_singleton_method(attribute) do
            Store.get(self, attribute, default: default)
          end
        end
      end

      def tl_cattr_writer(*attrs)
        attrs.each do |attribute|
          method_name = "#{attribute}=".to_sym
          define_method(method_name) do |new_value|
            Store.set(self.class, attribute, new_value)
          end

          define_singleton_method(method_name) do |new_value|
            Store.set(self, attribute, new_value)
          end
        end
      end
    end
  end
end