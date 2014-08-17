require "spec_helper"
require "tester/context"

describe Tester::Context do
  describe "loading tests" do
    let(:context) { Tester::Context.new("some_directory") }
    context "with no before or after" do
      before do
        allow(Dir).to receive(:entries).with("some_directory").and_return([".", "..", "a_context", "a_test"])
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with("some_directory/a_test").and_return(true)
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
    end
  end
  describe "running tests" do
    let(:context) { Tester::Context.new("some_directory") }
    # The UUT should not be partially mocked this much
    context "if the before fails" do
      let(:before) { double("before", passed?: false) }
      let(:test) { double(Tester::Test, result: double("result")) }
      let(:inner_context) { double(Tester::Context) }
      before do
        allow(context).to receive(:before).and_return(before)
        allow(context).to receive(:tests).and_return([test])
        allow(context).to receive(:contexts).and_return([inner_context])
      end
      it "should not run tests" do 
        allow(context).to receive(:report)
        expect(context).to_not receive(:run_tests!)
        context.run!
      end
      it "should report results" do
        expect(context).to receive(:report)
        context.run!
      end
    end
    context "reporting" do
      let(:test) { double(Tester::Test, result: double("result")) }
      let(:inner_context) { double(Tester::Context) }
      before do
        allow(context).to receive(:tests).and_return([test])
        allow(context).to receive(:contexts).and_return([inner_context])
      end
      it "should report the tests" do
        allow(inner_context).to receive(:report)
        expect(Tester::Reporter).to receive(:report).with(test.result)
        context.report
      end
      it "should report the contexts" do
        allow(Tester::Reporter).to receive(:report).with(test.result)
        expect(inner_context).to receive(:report)
        context.report
      end
    end
    it "should run the tests if the before passes" do
      before = double("before", passed?: true)
      allow(context).to receive(:before).and_return(before)
      expect(context).to receive(:run_tests!)
      context.run!
    end
    it "should run the contexts" do
      inner_context = double(Tester::Context)
      allow(context).to receive(:contexts).and_return([inner_context])
      allow(context).to receive(:tests).and_return([])
      expect(inner_context).to receive(:run!).once
      context.run!
    end
    it "should run the tests" do
      test = double(Tester::Test, result: nil)
      allow(context).to receive(:contexts).and_return([])
      allow(context).to receive(:tests).and_return([test])
      allow(Tester::Reporter).to receive(:report)
      expect(test).to receive(:run!).once
      context.run!
    end
    it "should report the test results" do
      test = double(Tester::Test, result: double("result"), run!: nil)
      allow(context).to receive(:contexts).and_return([])
      allow(context).to receive(:tests).and_return([test])
      expect(Tester::Reporter).to receive(:report).with(test.result).once
      context.run!
    end
    it "should run the after once the tests have completed" do
      after = double("after")
      allow(context).to receive(:after).and_return(after)
      allow(context).to receive(:run_tests!)
      expect(after).to receive(:run!)
      context.run!
    end
  end
  describe "listing tests" do
    let(:context) { Tester::Context.new("some_directory") }
    let(:test) { double(Tester::Test) }
    let(:another_test) { double(Tester::Test) }
    let(:inner_context) { double(Tester::Context, tests: [another_test]) }
    before do
      allow(context).to receive(:tests).and_return([test])
      allow(context).to receive(:contexts).and_return([inner_context])
    end
    it "should list the tests of the context and its context" do
      expect(context.all_tests).to eq([test, another_test])
    end
  end
end
