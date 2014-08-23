require "tester/refinements/string"

module Tester
  module Result
    
    # use the string refinement which adds ANSI colors
    using Tester::Refinements::String

    class Base
      attr_reader :name, :reason, :file
      def initialize(name, reason, file)
        @name = name
        @reason = reason
        @file = file
      end
    end
    
    # For tests that did not run
    class NoResult < Base
    end

    # For tests that passed
    class Pass < Base
    end

    # For tests that failed
    class Fail < Base
    end

    # For tests that were skipped
    class Skip < Base
    end
  end
end
