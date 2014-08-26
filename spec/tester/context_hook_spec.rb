require "spec_helper"
require "tester/context_hook"

describe Tester::ContextHook do
  let(:file) { "some_directory/hook" }
  let(:hook) { Tester::ContextHook.new(file) }
  it "should be initialized with a path to an executable" do
    expect(hook.file).to eq("some_directory/hook")
  end
  describe "running" do
    context "with an existing executable" do
      before { allow(File).to receive(:exists?).with(file).and_return(true) }
      it "should report as passing when the executable exits 0" do
        allow(Tester::Runner).to receive(:run).with(file).and_return(double("runner", exitstatus: 0))
        expect(hook.passed?).to eq(true)
      end
      it "should not report as passing when the executable does not exit 0" do
        allow(Tester::Runner).to receive(:run).with(file).and_return(double("runner", exitstatus: 1))
        expect(hook.passed?).to eq(false)
      end
      it "should not report as passing when the file is not executable" do
        allow(Tester::Runner).to receive(:run).with(file).and_return(double("runner", exitstatus: nil))
        expect(hook.passed?).to eq(false)
      end
      it "should report as failing when it fails" do
        allow(Tester::Runner).to receive(:run).with(file).and_return(double("runner", exitstatus: 1))
        expect(hook.result).to eq(Tester::Result::Fail)
      end
      it "should report as skipped when it skips" do
        allow(Tester::Runner).to receive(:run).with(file).and_return(double("runner", exitstatus: 2))
        expect(hook.result).to eq(Tester::Result::Skip)
      end
      it "should report as ignored when it cannot run" do
        allow(Tester::Runner).to receive(:run).with(file).and_return(double("runner", exitstatus: nil))
        expect(hook.result).to eq(Tester::Result::NoResult)
      end
    end
    context "with a nonexistent executable" do
      it "should report as passing" do
        allow(File).to receive(:exists?).with(file).and_return(false)
        expect(hook.passed?).to eq(true)
      end
    end
  end
end
