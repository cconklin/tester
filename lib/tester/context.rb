require "tester/test"
require "tester/context_hook"
require "tester/reporter"

module Tester
  class Context
    def self.hooks
      %w[before after]
    end
    def self.hook?(h)
      hooks.include? h
    end
    hooks.each do |name|
      define_method name do
        Tester::ContextHook.new(File.join(@root, name))
      end
    end

    def initialize(root)
      @root = root
    end

    def tests
      @tests ||= Dir.entries(@root).select { |e| File.file?(File.join(@root, e)) and not Context.hook?(e) }.map do |t|
        Tester::Test.new(File.join(@root, t))
      end
    end
    def contexts
      @contexts ||= Dir.entries(@root).reject { |e| File.file?(File.join(@root, e)) or [".", ".."].include?(e) }.map do |c|
        Tester::Context.new(File.join(@root, c))
      end
    end
    def run!
      if before.passed?
        run_tests!
        after.run!
      else
        set_no_run_reason! "Test set-up failed.\nFile: #{before.file}"
        report
      end
    end
    
    def report
      tests.each do |test|
        Tester::Reporter.report test.result
      end
      contexts.each do |context|
        context.report
      end
    end

    def all_tests
      # Explicit convesion to Array since the inject call on an empty array will return nil
      tests + Array(contexts.map(&:all_tests).inject(:+))
    end
    
    def failures
      all_tests.select(&:failed?)
    end

    def skipped
      all_tests.select(&:skipped?)
    end
    
    def ignored
      all_tests.reject(&:ran?)
    end

    private
   
    def run_tests!
      tests.each do |test|
        test.run!
        Tester::Reporter.report test.result
      end
      contexts.each do |context|
        context.run!
      end
    end

    def set_no_run_reason!(reason)
      all_tests.each do |test|
        test.reason = reason
      end
    end

  end
end
