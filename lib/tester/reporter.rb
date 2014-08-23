require "tester/refinements/string"
require "tester/result"
require "tester/formatter"

module Tester
  module Reporter
    using Tester::Refinements::String
    extend self
    
    def formatter=(formatter)
      @@formatter = formatter
    end
    
    def formatter
      @@formatter
    end

    def report(result)
      if formatter.inline
        print formatter.formatted_symbol(result)
      else
        puts formatter.formatted_symbol(result)
      end
    end

    # Display the text reason of why the test did what it did.
    def display(index, result)
      lines = formatter.display(result).split("\n")
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
      if failed == 0
        if skipped == 0
          if ignored == 0
            colorless_epilogue(examples, failed, skipped, ignored).color(formatter.color(Tester::Result::Pass))
          else
            colorless_epilogue(examples, failed, skipped, ignored).color(formatter.color(Tester::Result::NoResult))
          end
        else
          colorless_epilogue(examples, failed, skipped, ignored).color(formatter.color(Tester::Result::Skip))
        end
      else
        colorless_epilogue(examples, failed, skipped, ignored).color(formatter.color(Tester::Result::Fail))
      end
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
