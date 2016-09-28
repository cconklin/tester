require "tester/refinements/string"
require "tester/result"
require "tester/formatter"

module Tester
  class Reporter
    using Tester::Refinements::String
  
    attr_reader :formatter

    def initialize(formatter)
      @formatter = formatter
    end

    def report(test)
      if formatter.inline
        print formatter.formatted_symbol(test)
      else
        print formatter.formatted_symbol(test) + "\n"
      end
    end

    # Display the text reason of why the test did what it did.
    def display(index, test)
      lines = formatter.display(test).split("\n")
      puts "%4s) #{lines.shift}" % index
      lines.each do |line|
        puts "    " + line
      end
      puts
    end

    # Display the final result of the tests
    # (Number ran, number of failures. etc)
    def epilogue(*args)
      if formatter.colored?
        puts colored_epilogue *args
      else
        puts colorless_epilogue *args
      end
    end

    def colored_epilogue(examples, failed, skipped, ignored)
      if failed != 0
        color = formatter.color(Tester::Result::Fail)
      elsif skipped != 0
        color = formatter.color(Tester::Result::Skip)
      elsif ignored != 0
        color = formatter.color(Tester::Result::NoResult)
      else
        color = formatter.color(Tester::Result::Pass)
      end
      colorless_epilogue(examples, failed, skipped, ignored).color(color)
    end

    def colorless_epilogue(examples, failed, skipped, ignored)
      if skipped == 0 and ignored == 0
        "#{examples} example#{'s' if examples != 1}, #{failed} failure#{'s' if failed != 1}"
      elsif ignored == 0
        "#{examples} example#{'s' if examples != 1}, #{failed} failure#{'s' if failed != 1}, #{skipped} skipped"
      elsif skipped == 0
        "#{examples} example#{'s' if examples != 1}, #{failed} failure#{'s' if failed != 1}, #{ignored} ignored"
      else
        "#{examples} example#{'s' if examples != 1}, #{failed} failure#{'s' if failed != 1}, #{skipped} skipped, #{ignored} ignored"
      end
    end
  end
end
