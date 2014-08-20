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
    
    def name
      file.partition(base).last.gsub(/[_\/]/, " ").strip
    end

    def reason
      if @reason.to_s.empty?
        "No Reason Given"
      else
        @reason
      end
    end

    def ran?
      @result != Result::NoResult
    end

    def run!
      result = Tester::Runner.run(file)
      @reason = result.stdout
      # Capture the exit status, and map to a result object
      @result = case result.exitstatus
      when 0; Result::Pass
      when 1; Result::Fail
      when 2; Result::Skip
      when nil; Result::NoResult
      else; Result::Fail
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

    def epilogue
      result.new(name, reason, file)
    end

  end
end
