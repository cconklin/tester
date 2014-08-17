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
        # Kernel#system takes an executable as an argument, and returns
        # true if it exited 0, nil if it did not execute, false otherwise
        allow(hook).to receive(:system).with(file).and_return(true)
        expect(hook.passed?).to eq(true)
      end
      it "should not report as passing when the executable does not exit 0" do
        allow(hook).to receive(:system).with(file).and_return(false)
        expect(hook.passed?).to eq(false)
      end
      it "should not report as passing when the file is not executable" do
        allow(hook).to receive(:system).with(file).and_return(nil)
        expect(hook.passed?).to eq(false)
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
