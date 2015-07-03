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

  context "#tl_attr_accessor" do
    it "responds to both reader and writer methods" do
      expect(klass_instance).to respond_to(:tl_aa)
      expect(klass_instance).to respond_to(:tl_aa=)
    end
  end

  context "#tl_attr_reader" do
    it "responds to the reader method" do
      expect(klass_instance).to respond_to(:tl_ar)
    end

    it "does not respond to the writer method" do
      expect(klass_instance).to_not respond_to(:tl_ar=)
    end
  end

  context "#tl_attr_writer" do
    it "responds to the writer method" do
      expect(klass_instance).to respond_to(:tl_aw=)
    end

    it "does not respond to the reader method" do
      expect(klass_instance).to_not respond_to(:tl_aw)
    end
  end

  context "#tl_cattr_accessor" do
    it "responds to reader and writer methods at the class level" do
      expect(klass).to respond_to(:tl_ca)
      expect(klass).to respond_to(:tl_ca=)
    end

    it "responds to reader and writer methods at the instance level" do
      expect(klass_instance).to respond_to(:tl_ca)
      expect(klass_instance).to respond_to(:tl_ca=)
    end
  end

  context "#tl_cattr_reader" do
    it "responds to the reader method at the class level" do
      expect(klass).to respond_to(:tl_cr)
    end

    it "does not respond to the writer method at the class level" do
      expect(klass).to_not respond_to(:tl_cr=)
    end

    it "responds to the reader method at the instance level" do
      expect(klass_instance).to respond_to(:tl_cr)
    end

    it "does not respond to the writer method at the instance level" do
      expect(klass_instance).to_not respond_to(:tl_cr=)
    end
  end

  context "#tl_cattr_writer" do
    it "responds to the writer method at the class level" do
      expect(klass).to respond_to(:tl_cw=)
    end

    it "does not respond to the reader method at the class level" do
      expect(klass).to_not respond_to(:tl_cw)
    end

    it "responds to the writer method at the instance level" do
      expect(klass_instance).to respond_to(:tl_cw=)
    end

    it "does not respond to the reader method at the instance level" do
      expect(klass_instance).to_not respond_to(:tl_cw)
    end
  end
end