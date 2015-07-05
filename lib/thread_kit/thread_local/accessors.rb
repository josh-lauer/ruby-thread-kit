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
        options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
        visibility = options.delete(:visibility)
        if visibility && ![:public, :private, :protected].include?(visibility)
          raise "visibility must be :public, :private, or :protected"
        end
        attrs.each do |attribute|
          define_method(attribute) do
            Store.get(self, attribute, **options)
          end

          send(visibility, attribute) if visibility
        end
      end

      # thread local attr_writer
      def tl_attr_writer(*attrs, **options)
        options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
        visibility = options.delete(:visibility)
        if visibility && ![:public, :private, :protected].include?(visibility)
          raise "visibility must be :public, :private, or :protected"
        end
        attrs.each do |attribute|
          method_name = "#{attribute}=".to_sym
          define_method(method_name) do |new_value|
            Store.set(self, attribute, new_value, **options)
          end

          send(visibility, method_name) if visibility
        end
      end

      # thread local cattr_accesor
      def tl_cattr_accessor(*attrs, **options)
        tl_cattr_reader(*attrs, **options)
        tl_cattr_writer(*attrs, **options)
      end

      # thread local cattr_reader
      def tl_cattr_reader(*attrs, **options)
        options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
        visibility = options.delete(:visibility)
        if visibility && ![:public, :private, :protected].include?(visibility)
          raise "visibility must be :public, :private, or :protected"
        end
        options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
        attrs.each do |attribute|
          define_method(attribute) do
            Store.get(self.class, attribute, **options)
          end

          define_singleton_method(attribute) do
            Store.get(self, attribute, **options)
          end

          if visibility
            send(visibility, attribute)
            (class << self; self; end).instance_eval { send(visibility, attribute) }
          end
        end
      end

      # thread local cattr_writer
      def tl_cattr_writer(*attrs, **options)
        options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
        visibility = options.delete(:visibility)
        if visibility && ![:public, :private, :protected].include?(visibility)
          raise "visibility must be :public, :private, or :protected"
        end
        options = Hash[options.map{|(k,v)| [k.to_sym,v]}]
        attrs.each do |attribute|
          method_name = "#{attribute}=".to_sym
          define_method(method_name) do |new_value|
            Store.set(self.class, attribute, new_value, **options)
          end

          define_singleton_method(method_name) do |new_value|
            Store.set(self, attribute, new_value, **options)
          end

          if visibility
            send(visibility, method_name)
            (class << self; self; end).instance_eval { send(visibility, method_name) }
          end
        end
      end
    end
  end
end