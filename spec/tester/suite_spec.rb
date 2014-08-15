require "spec_helper"
require "tester/suite"
require "tester/context"

describe Tester::Suite do
  it "should have a context" do
    context = double Tester::Context  
    allow(Tester::Context).to receive(:new).with("some_directory").and_return(context)
    suite = Tester::Suite.new("some_directory")
    expect(suite.context).to eq(context)
  end
end
