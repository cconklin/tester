require "tester/result"
module Tester
  class Test
    # Sentinel Object for tests that cannot be executed
    class NotExecutable
      def self.to_s
        "The file was not executable"
      end
    end

    attr_reader :file, :result
    attr_accessor :reason
    def initialize(file)
      @file = file
      @result = Result::NoResult
    end
    
    def name
      file.gsub /[_\/]/, " "
    end

    def ran?
      @result != Result::NoResult
    end

    def run!
      if File.executable? file
        @reason = %x[#{file}] # Run the test file
        # Capture the exit status, and map to a result object
        @result = case $?.exitstatus
        when 0; Result::Pass
        when 1; Result::Fail
        when 2; Result::Skip
        end
      else
        @reason = NotExecutable
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
