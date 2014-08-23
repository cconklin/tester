require "tester/formatter"
Tester::Formatter.define_format "default" do
  pass ".", color: :green
  fail "F", color: :red
  skip "*", color: :yellow
  ignore "?"
end
