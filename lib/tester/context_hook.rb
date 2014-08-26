require "tester/runner"
require "tester/result"

module Tester
  class ContextHook
    # The hooks that run before and after tests
    attr_reader :file
    def initialize(file)
      @file = file
    end
    # Run the hook
    def run!
      @result ||= Tester::Runner.run(file)
    end
    # Run the hook and report if passing.
    # If the hook file does not exist, pass.
    # Only run the hook once, if it is run again,
    # report the previous result.
    def passed?
      run! unless @result
      @passed = if File.exists? file
        @result.exitstatus == 0
      else
        true
      end
    end
    def reason
      run! unless @result
      case @result.exitstatus
      when 1
        "Test set-up failed.\n" +
        "#{@result.stdout}File: #{file}".strip
      when 2
        "Test set-up skipped.\n" +
        "#{@result.stdout}File: #{file}".strip
      when nil; "Test set-up could not be run.\nFile: #{file}"
      end
    end
    # Map the exit status of the hook to the result of its tests
    def result
      run! unless @result
      case @result.exitstatus
      when 1; Tester::Result::Fail
      when 2; Tester::Result::Skip
      when nil; Tester::Result::NoResult
      end
    end
  end
end
