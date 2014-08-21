require "tester/refinements/string"

module Tester
  module Reporter
    using Tester::Refinements::String
    extend self
    
    # Configuration to use ANSI colors in the tty.
    def colored=(colored)
      @@colored = colored
    end
    def colored?
      @@colored
    end

    # Given a result from the result module, print it to the user.
    def report(result)
      if colored?
        print result.colored_icon
      else
        print result.icon
      end
    end
    
    # Display the text reason of why the test did what it did.
    def display(index, result)
      if colored?
        to_display = result.colored_epilogue
      else
        to_display = result.epilogue
      end
      lines = to_display.split("\n")
      puts "%4s) #{lines.shift}" % index
      lines.each do |line|
        puts "    " + line
      end
      puts
    end

    # Display the final result of the tests
    # (Number ran, number of failures. etc)
    def epilogue(*args)
      if colored?
        puts colored_epilogue *args
      else
        puts colorless_epilogue *args
      end
    end

    def colored_epilogue(examples, failed, skipped, ignored)
      if failed == 0
        if skipped == 0
          if ignored == 0
            colorless_epilogue(examples, failed, skipped, ignored).green
          else
            colorless_epilogue(examples, failed, skipped, ignored)
          end
        else
          colorless_epilogue(examples, failed, skipped, ignored).yellow
        end
      else
        colorless_epilogue(examples, failed, skipped, ignored).red
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
