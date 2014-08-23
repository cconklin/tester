require "tester/refinements/string"

module Tester
  module Result
    
    # For tests that did not run
    class NoResult; end

    # For tests that passed
    class Pass; end

    # For tests that failed
    class Fail; end

    # For tests that were skipped
    class Skip; end

    # For tests that errored
    class Error; end
  end
end
