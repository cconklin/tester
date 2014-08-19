require "spec_helper"
require "tester/reporter"

describe Tester::Reporter do
  it "should display the #colored_icon when colors are enabled" do
    result = double("Tester::Result", colored_icon: "colorful")
    Tester::Reporter.colored = true
    expect(Tester::Reporter).to receive(:print).with("colorful")
    Tester::Reporter.report result
  end
  it "should call the #icon method when colors are disabled" do
    result = double("Tester::Result", icon: "plain")
    Tester::Reporter.colored = false
    expect(Tester::Reporter).to receive(:print).with("plain")
    Tester::Reporter.report result
  end
  it "should display epilogues" do
    result = double("result", epilogue: "plain")
    Tester::Reporter.colored = false
    allow(Tester::Reporter).to receive(:puts)
    expect(result).to receive(:epilogue)
    Tester::Reporter.display 1, result
  end
  it "should display colored epilogues" do
    result = double("result", colored_epilogue: "colorful")
    Tester::Reporter.colored = true
    allow(Tester::Reporter).to receive(:puts)
    expect(result).to receive(:colored_epilogue)
    Tester::Reporter.display 1, result
  end
  describe "reporting final results" do
    context "without color" do
      before do
        Tester::Reporter.colored = false
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
