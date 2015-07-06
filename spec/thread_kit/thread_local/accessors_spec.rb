# These tests enforce a contract. That is to say, they do not ensure that the accessors
#   actually work. Instead, they test that the accessor methods define the appropriate
#   getters and setters, and that those getter and setter methods result in the correct
#   methods being called on ThreadKit::ThreadLocal::Store with the correct arguments.
#   ThreadKit::ThreadLocal::Store is tested separately.
describe ThreadKit::ThreadLocal::Accessors do

  let(:klass) do
    Class.new(Object) do
      extend ThreadKit::ThreadLocal::Accessors
      tl_attr_accessor :tl_aa
      tl_attr_reader :tl_ar
      tl_attr_writer :tl_aw
      tl_cattr_accessor :tl_ca
      tl_cattr_reader :tl_cr
      tl_cattr_writer :tl_cw
    end
  end

  let(:klass_instance) { klass.new }

  # assert that method_names are defined on klass_instance such that calls each results in the appropriate
  #   key being retrieved from ThreadKit::ThreadLocal::Store relative_to the appropriate object
  def assert_instance_method_reader_defined(*method_names, relative_to: klass_instance)
    method_names.each do |method_name|
      expect(klass_instance).to respond_to(method_name)
      expect(ThreadKit::ThreadLocal::Store).to receive(:get).with(relative_to, method_name, {}).and_return(:bar)
      expect(klass_instance.send(method_name)).to eql(:bar)
    end
  end

  # assert that method_name is defined on klass_instance such that calls to it result in the appropriate
  #   key being set in ThreadKit::ThreadLocal::Store relative_to the appropriate object
  def assert_instance_method_writer_defined(*method_names, relative_to: klass_instance)
    method_names.each do |method_name|
      method_name = (method_name.to_s + '=').squeeze('=').to_sym
      store_key = method_name.to_s.sub(/\=$/, '').to_sym
      expect(klass_instance).to respond_to(method_name)
      expect(ThreadKit::ThreadLocal::Store).to receive(:set).with(relative_to, store_key, :foo, {}).and_return(:foo)
      expect(klass_instance.send(method_name, :foo)).to eql(:foo)
    end
  end

  # assert that method_name is defined on klass such that calls to it result in the appropriate
  #   key being retrieved from ThreadKit::ThreadLocal::Store relative to klass
  def assert_singleton_method_reader_defined(*method_names)
    method_names.each do |method_name|
      expect(klass).to respond_to(method_name)
      expect(ThreadKit::ThreadLocal::Store).to receive(:get).with(klass, method_name, {}).and_return(:bar)
      expect(klass.send(method_name)).to eql(:bar)
    end
  end

  # assert that method_name is defined on klass such that calls to it result in the appropriate
  #   key being set in ThreadKit::ThreadLocal::Store relative to klass
  def assert_singleton_method_writer_defined(*method_names)
    method_names.each do |method_name|
      method_name = (method_name.to_s + '=').squeeze('=').to_sym
      store_key = method_name.to_s.sub(/\=$/, '').to_sym
      expect(klass).to respond_to(method_name)
      expect(ThreadKit::ThreadLocal::Store).to receive(:set).with(klass, store_key, :foo, {}).and_return(:foo)
      expect(klass.send(method_name, :foo)).to eql(:foo)
    end
  end

  # assert that klass_instance does not have the specified method defined
  def assert_instance_method_not_defined(*method_names)
    method_names.each do |method_name|
      expect(klass_instance).to_not respond_to(method_name)
    end
  end

  # assert that klass does not have the specified method defined
  def assert_singleton_method_not_defined(*method_names)
    method_names.each do |method_name|
      expect(klass).to_not respond_to(method_name)
    end
  end

  describe "#tl_attr_accessor" do
    it("defines an instance reader") { assert_instance_method_reader_defined(:tl_aa) }
    it("defines an instance writer") { assert_instance_method_writer_defined(:tl_aa=) }
    it("does not define class accessors") { assert_singleton_method_not_defined(:tl_aa, :tl_aa=) }
  end

  describe "#tl_attr_reader" do
    it("defines an instance reader") { assert_instance_method_reader_defined(:tl_ar) }
    it("does not define an instance writer") { assert_instance_method_not_defined(:tl_ar=) }
    it("does not define class accessors") { assert_singleton_method_not_defined(:tl_ar, :tl_ar=) }
  end

  describe "#tl_attr_writer" do
    it("defines an instance writer") { assert_instance_method_writer_defined(:tl_aw=) }
    it("does not define an instance reader") { assert_instance_method_not_defined(:tl_aw) }
    it("does not define class accessors") { assert_singleton_method_not_defined(:tl_aw, :tl_aw=) }
  end

  describe "#tl_cattr_accessor" do
    it("defines an instance reader") { assert_instance_method_reader_defined(:tl_ca, relative_to: klass) }
    it("defines an instance writer") { assert_instance_method_writer_defined(:tl_ca=, relative_to: klass) }
    it("defines a class reader") { assert_singleton_method_reader_defined(:tl_ca) }
    it("defines a class writer") { assert_singleton_method_writer_defined(:tl_ca=) }
  end

  describe "#tl_cattr_reader" do
    it("defines an instance reader") { assert_instance_method_reader_defined(:tl_cr, relative_to: klass) }
    it("does not define an instance writer") { assert_instance_method_not_defined(:tl_cr=) }
    it("defines a class reader") { assert_singleton_method_reader_defined(:tl_cr) }
    it("does not define a class writer") { assert_singleton_method_not_defined(:tl_cr=) }
  end

  describe "#tl_cattr_writer" do
    it("does not define an instance reader") { assert_instance_method_not_defined(:tl_cw) }
    it("defines an instance writer") { assert_instance_method_writer_defined(:tl_cw=, relative_to: klass) }
    it("does not define a class reader") { assert_singleton_method_not_defined(:tl_cw) }
    it("defines a class writer") { assert_singleton_method_writer_defined(:tl_cw=) }
  end
end
