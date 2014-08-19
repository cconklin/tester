require "tester/test"
require "benchmark"

module Tester
  class Suite
    attr_reader :contexts
    def initialize(files)
      @contexts = files.map do |root|
        split_root = root.split("/")
        if split_root.include? "test"
          Tester::Context.new(root, File.join(split_root[0..split_root.rindex("test")]))
        else
          Tester::Context.new(root, root)
        end
      end
    end
    def run!
      time = Benchmark.measure { @contexts.each {|c| c.run! } }.real
      report(time)
    end

    def report(time)
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
      puts "Finished in #{time} seconds"
      Reporter.epilogue all_tests.count, failures.count, skipped.count, ignored.count
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
  end
end
