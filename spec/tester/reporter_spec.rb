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
    expect(Tester::Reporter).to receive(:print).with("plain")
    Tester::Reporter.display result
  end
  it "should display colored epilogues" do
    result = double("result", colored_epilogue: "colorful")
    Tester::Reporter.colored = true
    expect(Tester::Reporter).to receive(:print).with("colorful")
    Tester::Reporter.display result
  end
end
