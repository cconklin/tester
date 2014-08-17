module Tester
  class ContextHook
    attr_reader :file
    def initialize(file)
      @file = file
    end
    def run!
      # Even though nil evaluates to false, force it to be returned as false
      (system file) || false
    end
    def passed?
      @passed ||= if File.exists? file
        run!
      else
        true
      end
    end
  end
end
