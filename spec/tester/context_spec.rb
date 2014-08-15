require "spec_helper"
require "tester/context"

describe Tester::Context do
  describe "loading tests" do
    let(:context) { Tester::Context.new("some_directory") }
    context "with no before or after" do
      before do
        allow(Dir).to receive(:entries).with("some_directory").and_return([".", "..", "a_context", "a_test"])
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with("a_test").and_return(true)
      end
      it "should find test files" do
        test = double(Tester::Test)
        allow(Tester::Test).to receive(:new).with("some_directory/a_test").and_return(test)
        expect(context.tests).to eq([test])
      end
      it "should find contexts" do
        context # Create the context before the contructor is stubbed
        inner_context = double(Tester::Context)
        allow(Tester::Context).to receive(:new).with("some_directory/a_context").and_return(inner_context)
        expect(context.contexts).to eq([inner_context])
      end
      it "should not have a before" do
        expect(context.before).to be_nil
      end
      it "should not have an after" do
        expect(context.after).to be_nil
      end
    end
    context "with a before" do
      before do
        allow(Dir).to receive(:entries).with("some_directory").and_return(["a_test", "before"])
        allow(File).to receive(:file?).and_return(true)
      end
      it "should not have the before in its tests" do
        test = double(Tester::Test)
        allow(Tester::Test).to receive(:new).with("some_directory/a_test").and_return(test)
        expect(context.tests).to eq([test])
      end
      it "should reveal its before" do
        before = double(Tester::Test)
        allow(Tester::Test).to receive(:new).with("some_directory/before").and_return(before)
        expect(context.before).to eq(before)
      end
    end
    context "with an after" do
      before do
        allow(Dir).to receive(:entries).with("some_directory").and_return(["a_test", "after"])
        allow(File).to receive(:file?).and_return(true)
      end
      it "should not have the after in its tests" do
        test = double(Tester::Test)
        allow(Tester::Test).to receive(:new).with("some_directory/a_test").and_return(test)
        expect(context.tests).to eq([test])
      end
      it "should reveal its after" do
        after = double(Tester::Test)
        allow(Tester::Test).to receive(:new).with("some_directory/after").and_return(after)
        expect(context.after).to eq(after)
      end
    end
  end
end
