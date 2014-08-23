Tester::Formatter.define_format "default" do
  pass ".", color: :green
  fail "F", color: :red
  skip "*", color: :yellow
  error "E", color: :red
  ignore "?"
end
