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
    it "should accept a 'symbol'" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".")
      expect(formatter.symbol(Tester::Result::Pass)).to eq(".")
    end
    it "should default to a default color" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".")
      expect(formatter.color(Tester::Result::Pass)).to eq(:default)
    end
    it "should allow colors to be overridden" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".", color: :green)
      expect(formatter.color(Tester::Result::Pass)).to eq(:green)
    end
    it "should color the symbol when colors are enabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.colored = true
      formatter.pass("green", color: :green)
      expect(formatter.formatted_symbol(Tester::Result::Pass)).to eq("\033[32mgreen\033[0m")
    end
    it "should not color the symbol when color are enabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.pass(".", color: :green)
      expect(formatter.formatted_symbol(Tester::Result::Pass)).to eq(".")
    end
  end
  describe "defining failing behavior" do
    it "should accept a 'symbol'" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".")
      expect(formatter.symbol(Tester::Result::Fail)).to eq(".")
    end
    it "should default to a default color" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".")
      expect(formatter.color(Tester::Result::Fail)).to eq(:default)
    end
    it "should allow colors to be overridden" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".", color: :green)
      expect(formatter.color(Tester::Result::Fail)).to eq(:green)
    end
    it "should color the symbol when colors are enabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.colored = true
      formatter.fail("green", color: :green)
      expect(formatter.formatted_symbol(Tester::Result::Fail)).to eq("\033[32mgreen\033[0m")
    end
    it "should not color the symbol when colors are disabled" do
      formatter = Tester::Formatter.new("my_formatter")
      formatter.fail(".", color: :green)
      expect(formatter.formatted_symbol(Tester::Result::Fail)).to eq(".")
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
      formatter = Tester::Formatter.formatter("test_format")
      expect(formatter.symbol(Tester::Result::Skip)).to eq("*")
      expect(formatter.color(Tester::Result::Skip)).to eq(:yellow)
    end
  end
end
