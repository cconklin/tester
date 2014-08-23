require "spec_helper"
require "tester/reporter"

describe Tester::Reporter do
  describe "reporting as tests return" do
    context "inline" do
      let(:formatter) { double("formatter", inline: true) }
      before do
        Tester::Reporter.formatter = formatter
      end
      it "should display the icon" do
        expect(formatter).to receive(:formatted_symbol)
        expect(Tester::Reporter).to receive(:print)
        Tester::Reporter.report double("test", result: Tester::Result::Pass)
      end
    end
    context "line delimited" do
      let(:formatter) { double("formatter", inline: false) }
      before do
        Tester::Reporter.formatter = formatter
      end
      it "should display the icon" do
        expect(formatter).to receive(:formatted_symbol)
        expect(Tester::Reporter).to receive(:puts)
        Tester::Reporter.report double("test", result: Tester::Result::Pass)
      end
    end
  end
  describe "reporting final results" do
    context "with color" do
      let(:formatter) { double("formatter", colored?: true) }
      before do
        Tester::Reporter.formatter = formatter
        allow(formatter).to receive(:color).with(Tester::Result::Pass).and_return(:green)
      end
      it "should display in color" do
        expect(Tester::Reporter).to receive(:puts).with("\033[32m5 examples, 0 failures\033[0m")
        Tester::Reporter.epilogue(5, 0, 0, 0)
      end
    end
    context "without color" do
      let(:formatter) { double("formatter", colored?: false) }
      before do
        Tester::Reporter.formatter = formatter
      end
      it "should report the number of examples with no failures" do
        expect(Tester::Reporter).to receive(:puts).with("5 examples, 0 failures")
        Tester::Reporter.epilogue(5, 0, 0, 0)
      end
      it "should report the number of failures when there is a failure" do
        expect(Tester::Reporter).to receive(:puts).with("5 examples, 1 failure")
        Tester::Reporter.epilogue(5, 1, 0, 0)
      end
      it "should report the number of failures when there are failures" do
        expect(Tester::Reporter).to receive(:puts).with("5 examples, 2 failures")
        Tester::Reporter.epilogue(5, 2, 0, 0)
      end
      it "should report the number of skips when present" do 
        expect(Tester::Reporter).to receive(:puts).with("5 examples, 0 failures, 1 skipped")
        Tester::Reporter.epilogue(5, 0, 1, 0)
      end
      it "should report the number of ignored tests, when present" do
        expect(Tester::Reporter).to receive(:puts).with("5 examples, 0 failures, 1 ignored")
        Tester::Reporter.epilogue(5, 0, 0, 1)
      end
      it "should report the number of skipped and ignored when both are present" do
        expect(Tester::Reporter).to receive(:puts).with("5 examples, 0 failures, 1 skipped, 1 ignored")
        Tester::Reporter.epilogue(5, 0, 1, 1)
      end
    end
  end
end
