require "tester/test"

module Tester
  class Suite
    attr_reader :context
    def initialize(root)
      @context = Tester::Context.new(root)
    end
  end
end
