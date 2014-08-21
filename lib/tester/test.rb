require "tester/result"
require "tester/runner"

module Tester
  class Test
    attr_reader :file, :result, :base
    attr_writer :reason
    def initialize(file, base)
      @file = file
      @base = base
      @result = Result::NoResult
    end
    
    # Turn the path into a test name
    # 'base' is the test directory, and the path before it is stripped.
    def name
      file.partition(base).last.gsub(/[_\/]/, " ").strip
    end

    # Report a reason for test status, with default
    def reason
      if @reason.to_s.empty?
        "No Reason Given"
      else
        @reason
      end
    end
    
    # Report if a test ran.
    # All tests that ran have a result
    def ran?
      @result != Result::NoResult
    end

    # Run the test.
    # Convert the exitcode of the test into a result
    def run!
      result = Tester::Runner.run(file)
      @reason = result.stdout
      # Capture the exit status, and map to a result object
      @result = case result.exitstatus
      when 0; Result::Pass
      when 1; Result::Fail
      when 2; Result::Skip
      when nil; Result::NoResult
      else; Result::Fail # Might become error in the future
      end
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
