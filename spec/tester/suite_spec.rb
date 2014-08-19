require "spec_helper"
require "tester/suite"
require "tester/context"

describe Tester::Suite do
  let(:context) { double Tester::Context }
  let(:suite) { Tester::Suite.new(["some_directory"]) }
  before do
    allow(Tester::Context).to receive(:new).with("some_directory", "some_directory").and_return(context)
  end
  it "should have contexts" do
    expect(suite.contexts).to eq([context])
  end
  it "should run its contexts" do
    allow(suite).to receive(:report)
    expect(context).to receive(:run!)
    suite.run!
  end
  it "should list skips" do
    test = double("test")
    allow(context).to receive(:skipped).and_return([test])
    expect(suite.skipped).to eq([test])
  end
  it "should list failures" do
    test = double("test")
    allow(context).to receive(:failures).and_return([test])
    expect(suite.failures).to eq([test])
  end
  it "should list the tests that were not run" do
    test = double("test")
    allow(context).to receive(:ignored).and_return([test])
    expect(suite.ignored).to eq([test])
  end
  it "should list the tests that ran" do
    test = double("test")
    allow(context).to receive(:ran).and_return([test])
    expect(suite.ran).to eq([test])
  end
  it "should list the tests that passed" do
    test = double("test")
    allow(context).to receive(:passed).and_return([test])
    expect(suite.passed).to eq([test])
  end
end
