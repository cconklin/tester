require "tester/test"

module Tester
  class Context
    
    def self.special(name)
      name = name.to_s
      self.specials << name
      send :define_method, name do
        if Dir.entries(@root).include? name
          Tester::Test.new(File.join(@root, name))
        end
      end
    end
    def self.specials
      @@specials ||= []
    end
    def self.normal?(e)
      not specials.include? e
    end

    special "before"
    special "after"

    def initialize(root)
      @root = root
    end

    def tests
      Dir.entries(@root).select { |e| File.file? e and Context.normal?(e) }.map do |t|
        Tester::Test.new(File.join(@root, t))
      end
    end
    def contexts
      Dir.entries(@root).reject { |e| File.file?(e) or [".", ".."].include?(e) }.map do |c|
        Tester::Context.new(File.join(@root, c))
      end
    end
  end
end
