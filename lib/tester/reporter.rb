require "tester/refinements/string"

module Tester
  module Reporter
    using Tester::Refinements::String
    extend self

    def colored=(colored)
      @@colored = colored
    end
    def colored?
      @@colored
    end
    def report(result)
      if colored?
        print result.colored_icon
      else
        print result.icon
      end
    end
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
    
    def epilogue(*args)
      if colored?
        puts colored_epilogue *args
      else
        puts colorless_epilogue *args
      end
    end

    def colored_epilogue(run, failed, skipped, ignored)
      if failed == 0
        if skipped == 0
          if ignored == 0
            colorless_epilogue(run, failed, skipped, ignored).green
          else
            colorless_epilogue(run, failed, skipped, ignored)
          end
        else
          colorless_epilogue(run, failed, skipped, ignored).yellow
        end
      else
        colorless_epilogue(run, failed, skipped, ignored).red
      end
    end

    def colorless_epilogue(run, failed, skipped, ignored)
      if skipped == 0 and ignored == 0
        "#{run} examples, #{failed} failure#{'s' if failed != 1}"
      elsif ignored == 0
        "#{run} examples, #{failed} failure#{'s' if failed != 1}, #{skipped} skipped"
      elsif skipped == 0
        "#{run} examples, #{failed} failure#{'s' if failed != 1}, #{ignored} ignored"
      else
        "#{run} examples, #{failed} failure#{'s' if failed != 1}, #{skipped} skipped, #{ignored} ignored"
      end
    end
  end
end
