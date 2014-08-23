require "tester/test"
require "benchmark"

module Tester
  class Suite
    attr_reader :contexts
    def initialize(files)
      @load_time = Benchmark.measure do
        @contexts = files.map do |root|
          # Try to determine where the root test directory is, to provide better test naming
          split_root = root.split("/")
          if split_root.include? "test"
            # Find the last instance of "test" in the path, and call it the root.
            Tester::Context.new(root, File.join(split_root[0..split_root.rindex("test")]))
          else
            Tester::Context.new(root, root)
          end
        end
      end.real
      @run_time = 0.0
    end

    # Run the suite
    def run!
      # Time how long it takes to run the tests for all the contexts
      @run_time = Benchmark.measure { @contexts = @contexts.map {|c| c.run! } }.real
      report
    end

    # Report test results
    def report
      # If there were not tests found (executable or not), report it to the user
      if all_tests.empty?
        puts "[No Tests Found]"
      else
        puts
      end
      puts
      puts "Failures:" unless failures.empty?
      failures.each.with_index do |test, index|
        # Indexing starts at 0, make it start at 1
        Reporter.display index + 1, test
      end
      puts "Skipped:" unless skipped.empty?
      skipped.each.with_index do |test, index|
        Reporter.display index + 1, test
      end
      puts "Not Run:" unless ignored.empty?
      ignored.each.with_index do |test, index|
        Reporter.display index + 1, test
      end
      puts "Finished in #{@run_time} seconds (files took #{@load_time} seconds to load)"
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
