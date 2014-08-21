require "tester/result"
require "tester/runner"

module Tester
  class Test
    attr_reader :file, :result, :base, :reason
    def initialize(file, base, result = Result::NoResult, reason = "No Reason Given")
      @file = file
      @base = base
      @result = result
      @reason = reason
    end
    
    # Turn the path into a test name
    # 'base' is the test directory, and the path before it is stripped.
    def name
      file.partition(base).last.gsub(/[_\/]/, " ").strip
    end

    def set_reason(new_reason)
      Tester::Test.new(file, base, result, new_reason)
    end
    # Report if a test ran.
    # All tests that ran have a result
    def ran?
      @result != Result::NoResult
    end

    # Run the test.
    # Convert the exitcode of the test into a result
    def run!
      test_result = Tester::Runner.run(file)
      reason = test_result.stdout
      # Capture the exit status, and map to a result object
      result = case test_result.exitstatus
      when 0; Result::Pass
      when 1; Result::Fail
      when 2; Result::Skip
      when nil; Result::NoResult
      else; Result::Fail # Might become error in the future
      end
      Tester::Test.new(file, base, result, reason)
    end

    def passed?
      @result == Result::Pass
    end
    
    def failed?
      @result == Result::Fail
    end
    
    def skipped?
      @result == Result::Skip
    end
    
    # Get the reason for why a test had the result it did.
    def epilogue
      result.new(name, reason, file)
    end

  end
end
