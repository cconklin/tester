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
    def display(result)
      if colored?
        print result.colored_epilogue
      else
        print result.epilogue
      end
    end
  end
end
