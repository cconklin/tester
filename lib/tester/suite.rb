require "tester/test"

module Tester
  class Suite
    attr_reader :contexts
    def initialize(files)
      @contexts = files.map { |root| Tester::Context.new(root, root) }
    end
    def run!
      @contexts.each {|c| c.run! }
      report
    end

    def report
      puts
      puts "Failures:" unless failures.empty?
      failures.each.with_index do |test, index|
        Reporter.display index + 1, test.epilogue
      end
      puts "Skipped:" unless skipped.empty?
      skipped.each.with_index do |test, index|
        Reporter.display index + 1, test.epilogue
      end
      puts "Not Run:" unless ignored.empty?
      ignored.each.with_index do |test, index|
        Reporter.display index + 1, test.epilogue
      end
      Reporter.epilogue ran.count, failures.count, skipped.count, ignored.count
      puts
    end
    def all_tests
      @contexts.map {|c| c.all_tests }.inject(:+)
    end
    def skipped
      @contexts.map(&:skipped).inject(:+)
    end
    def failures
      @contexts.map(&:failures).inject(:+)
    end
    def ignored
      @contexts.map(&:ignored).inject(:+)
    end
    def ran
      @contexts.map(&:ran).inject(:+)
    end
    def passed
      @contexts.map(&:passed).inject(:+)
    end
  end
end
