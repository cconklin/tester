module Tester
  module Reporter
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
    end
  end
end
