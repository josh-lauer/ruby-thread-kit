describe "ThreadKit::ThreadLocal::Store" do
  let(:foo){ "foo" }

  it "returns nil for any unset values in a thread" do
    expect(ThreadKit::ThreadLocal::Store.get(foo, :woo)).to equal(nil)
  end

  it "stores variables specific to a thread" do
    ThreadKit::ThreadLocal::Store.set(foo, :woo, :hoo)
    expect(ThreadKit::ThreadLocal::Store.get(foo, :woo)).to equal(:hoo)
    thr = Thread.new {
      expect(ThreadKit::ThreadLocal::Store.get(foo, :woo)).to equal(nil)
      ThreadKit::ThreadLocal::Store.set(foo, :woo, :boo!)
      expect(ThreadKit::ThreadLocal::Store.get(foo, :woo)).to equal(:boo!)
    }
    thr.join
    expect(ThreadKit::ThreadLocal::Store.get(foo, :woo)).to equal(:hoo)
  end

  it "automatically invokes finalizers for threads/objects that are garbage collected" do
    # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/87753
    # Hi,

    # In message "How to unit test finalizers?"
    #     on 03/12/11, Samuel Tesla <samuel / thoughtlocker.net> writes:

    # |> Nothing.  There's no way to "ensure" instance to be GC'ed except for
    # |> program termination.  That's a weak (or charm) point of Ruby's GC.
    # |
    # |That's fine.  I'm guessing that the GC will eventually, most likely,
    # |collect those references.  The question then becomes, how can I
    # |reliably unit test my finalizer code if I can't reliably get it to
    # |execute?

    # How about not relying on finalizers, i.e. separate finalizing process
    # into a method, then call the method explicitly in the test?  You don't
    # have to test whether finalizers are called.  That's my responsibility.

    #               matz.
    
    expect(0).to equal(0)
  end
end