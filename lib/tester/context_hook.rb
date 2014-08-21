require "tester/runner"

module Tester
  class ContextHook
    # The hooks that run before and after tests
    attr_reader :file
    def initialize(file)
      @file = file
    end
    # Run the hook
    def run!
      Tester::Runner.run(file)
    end
    # Run the hook and report if passing.
    # If the hook file does not exist, pass.
    # Only run the hook once, if it is run again,
    # report the previous result.
    def passed?
      @passed ||= if File.exists? file
        run!.exitstatus == 0
      else
        true
      end
    end
  end
end
