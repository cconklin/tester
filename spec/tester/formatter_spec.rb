require "spec_helper"
require "tester/formatter"

describe Tester::Formatter do
  it "should have a name" do
    formatter = Tester::Formatter.new("my_formatter")
    expect(formatter.name).to eq("my_formatter")
  end
  it "should be inline by default" do
    formatter = Tester::Formatter.new("my_formatter")
    expect(formatter.inline).to eq(true)
  end
  it "should allow the inline behavior to be overridden" do
    formatter = Tester::Formatter.new("my_formatter", inline: false)
    expect(formatter.inline).to eq(false)
  end
  it "should allow colors to be enabled" do
    formatter = Tester::Formatter.new("my_formatter")
    formatter.colored = true
    expect(formatter.colored?).to eq(true)
  end
  describe "defining passing behavior" do
    let(:test) { double("test", result: Tester::Result::Pass) }
    it "should accept a 'symbol'" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".")
      expect(formatter.symbol(test)).to eq(".")
    end
    it "should default to a default color" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".")
      expect(formatter.color(test.result)).to eq(:default)
    end
    it "should allow colors to be overridden" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".", color: :green)
      expect(formatter.color(test.result)).to eq(:green)
    end
    it "should color the symbol when colors are enabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.colored = true
      formatter.pass("green", color: :green)
      expect(formatter.formatted_symbol(test)).to eq("\033[32mgreen\033[0m")
    end
    it "should not color the symbol when color are enabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".", color: :green)
      expect(formatter.formatted_symbol(test)).to eq(".")
    end
  end
  describe "defining failing behavior" do
    let(:test) { double("test", result: Tester::Result::Fail) }
    it "should accept a 'symbol'" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".")
      expect(formatter.symbol(test)).to eq(".")
    end
    it "should default to a default color" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".")
      expect(formatter.color(test.result)).to eq(:default)
    end
    it "should allow colors to be overridden" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".", color: :green)
      expect(formatter.color(test.result)).to eq(:green)
    end
    it "should color the symbol when colors are enabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.colored = true
      formatter.fail("green", color: :green)
      expect(formatter.formatted_symbol(test)).to eq("\033[32mgreen\033[0m")
    end
    it "should not color the symbol when colors are disabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".", color: :green)
      expect(formatter.formatted_symbol(test)).to eq(".")
    end
    it "should raise an error if nothing is passed" do
      formatter = Tester::Formatter.new("my_formatter")
      expect { formatter.fail }.to raise_error(ArgumentError)
    end
  end
  describe "defining behavior with a block" do
    let(:test) { double("test", name: "foo", result: Tester::Result::Fail) }
    it "should not accept a symbol" do
      formatter = Tester::Formatter.new("my_formatter")
      expect { formatter.fail("F") {|test| "F" } }.to raise_error(ArgumentError)
    end
    it "should allow custom results" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail {|test| test.name}
      expect(formatter.formatted_symbol(test)).to eq("foo")
    end
  end
  describe "the DSL" do
    before do
      Tester::Formatter.define_format "test_format", inline: true do
        pass ".", color: :green
        fail "F", color: :red
        skip "*", color: :yellow
        ignore "?"
      end
    end
    it "should set up the formatter" do
      test = double("test", result: Tester::Result::Skip)
      formatter = Tester::Formatter.formatter("test_format")
      expect(formatter.symbol(test)).to eq("*")
      expect(formatter.color(test.result)).to eq(:yellow)
    end
  end
end
