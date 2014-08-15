require "spec_helper"
require "tester/test"

describe Tester::Test do
  describe "loading the test file" do
    let(:test) { Tester::Test.new("a_file") }
    it "should load a file" do
      expect(test.file).to eq("a_file")
    end
  end
  describe "giving the test a human readable name" do
    it "should convert underscores to spaces" do
      test = Tester::Test.new("a_file")
      expect(test.name).to eq("a file")
    end
    it "should convert slashes to spaces" do
      test = Tester::Test.new("context/test")
      expect(test.name).to eq("context test")
    end
  end
  context "when not yet run" do
    let(:test) { Tester::Test.new("a_file") }
    it "should return false when #ran? is called" do
      expect(test.ran?).to eq(false)
    end
    it "should have no result" do
      expect(test.result).to eq(Tester::Test::NoResult)
    end
  end
  describe "running a test" do
    let :test do
      allow(File).to receive(:executable?).with("a_file").and_return(true)
      Tester::Test.new("a_file")
    end
    context "that cannot run" do
      let(:bad_test) { Tester::Test.new("not_executable") }
      before do
        allow(File).to receive(:executable?).with("not_executable").and_return(false)
        bad_test.run!
      end
      it "should raise an exception when the file is not executable" do
        expect(bad_test.result).to eq(Tester::Test::NoResult)
      end
      it "should report as not having run" do
        expect(bad_test.ran?).to eq(false)
      end
      it "should set the reason to NotExecutable" do
        expect(bad_test.reason).to eq(Tester::Test::NotExecutable)
      end
    end
    context "that passes" do
      before do
        %x{ exit 0 }
        allow(test).to receive(:`).with("a_file").and_return("a result")
        test.run!
      end
      it "should set the result to passing" do
        expect(test.result).to eq(Tester::Test::Pass)
      end
      it "should set the reason to the output of the test" do
        expect(test.reason).to eq("a result")
      end
      it "should report as passing" do
        expect(test.passed?).to eq(true)
      end
      it "should not report as failing" do
        expect(test.failed?).to eq(false)
      end
    end
    context "that fails" do
      before do
        %x{ exit 1 }
        allow(test).to receive(:`).with("a_file").and_return("a result")
        test.run!
      end
      it "should set the result to failing" do
        expect(test.result).to eq(Tester::Test::Fail)
      end
      it "should set the reason to the output of the test" do
        expect(test.reason).to eq("a result")
      end
      it "should report as failing" do
        expect(test.failed?).to eq(true)
      end
      it "should not report as passing" do
        expect(test.passed?).to eq(false)
      end
    end
    context "that was skipped" do
      before do
        %x{ exit 2 }
        allow(test).to receive(:`).with("a_file").and_return("a result")
        test.run!
      end
      it "should set the result to skipped" do
        expect(test.result).to eq(Tester::Test::Skip)
      end
      it "should set the reason to the output of the test" do
        expect(test.reason).to eq("a result")
      end
      it "should report as skipped" do
        expect(test.skipped?).to eq(true)  
      end
    end
  end
end
