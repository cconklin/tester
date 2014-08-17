require "tester/test"

module Tester
  class Suite
    attr_reader :contexts
    def initialize(files)
      @contexts = files.map {|root| Tester::Context.new(root) }
    end
    def run!
      @contexts.each {|c| c.run! }
      puts "\n"
      all_tests.each do |test|
        Reporter.display test.epilogue
      end
    end
    def all_tests
      @contexts.map {|c| c.all_tests }.inject(:+)
    end
  end
end
