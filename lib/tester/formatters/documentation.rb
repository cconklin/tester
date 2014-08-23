Tester::Formatter.define_format "documentation", inline: false do
  pass color: :green do |test|
    test.name
  end
  fail color: :red do |test|
    "#{test.name} (FAILED)"
  end
  skip color: :yellow do |test|
    "#{test.name} (SKIPPED)"
  end
  ignore do |test|
    "#{test.name} (NOT RUN)"
  end
  error color: :red do |test|
    "#{test.name} (ERROR)"
  end
end
