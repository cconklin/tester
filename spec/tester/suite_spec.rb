require "spec_helper"
require "tester/suite"
require "tester/context"

describe Tester::Suite do
  let(:context) { double Tester::Context }
  let(:suite) { Tester::Suite.new(["some_directory"]) }
  before do
    allow(Tester::Context).to receive(:new).with("some_directory").and_return(context)
  end
  it "should have contexts" do
    expect(suite.contexts).to eq([context])
  end
  it "should run its contexts" do
    allow(suite).to receive(:all_tests).and_return([])
    expect(context).to receive(:run!)
    suite.run!
  end
  it "should list all tests" do
    test = double("test")
    allow(context).to receive(:all_tests).and_return([test])
    expect(suite.all_tests).to eq([test])
  end
end
