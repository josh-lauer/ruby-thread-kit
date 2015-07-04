module ThreadKit
  module ThreadLocal
    module Accessors
      # thread local attr_accessor
      def tl_attr_accessor(*attrs, **options)
        tl_attr_reader(*attrs, **options)
        tl_attr_writer(*attrs, **options)
      end

      # thread local attr_reader
      def tl_attr_reader(*attrs, **options)
        attrs.each do |attribute|
          define_method(attribute) do
            Store.get(self, attribute, **options)
          end
        end
      end

      # thread local attr_writer
      def tl_attr_writer(*attrs, **options)
        attrs.each do |attribute|
          method_name = "#{attribute}=".to_sym
          define_method(method_name) do |new_value|
            Store.set(self, attribute, new_value, **options)
          end
        end
      end

      # thread local cattr_accesor
      def tl_cattr_accessor(*attrs, **options)
        tl_cattr_reader(*attrs, **options)
        tl_cattr_writer(*attrs, **options)
      end

      # thread local cattr_reader
      def tl_cattr_reader(*attrs, **options)
        attrs.each do |attribute|
          define_method(attribute) do
            Store.get(self.class, attribute, **options)
          end

          define_singleton_method(attribute) do
            Store.get(self, attribute, **options)
          end
        end
      end

      # thread local cattr_writer
      def tl_cattr_writer(*attrs, **options)
        attrs.each do |attribute|
          method_name = "#{attribute}=".to_sym
          define_method(method_name) do |new_value|
            Store.set(self.class, attribute, new_value, **options)
          end

          define_singleton_method(method_name) do |new_value|
            Store.set(self, attribute, new_value, **options)
          end
        end
      end
    end
  end
end