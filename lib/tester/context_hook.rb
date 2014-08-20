require "tester/runner"

module Tester
  class ContextHook
    attr_reader :file
    def initialize(file)
      @file = file
    end
    def run!
      Tester::Runner.run(file)
    end
    def passed?
      @passed ||= if File.exists? file
        run!.exitstatus == 0
      else
        true
      end
    end
  end
end
