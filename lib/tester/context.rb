require "tester/test"
require "tester/context_hook"
require "tester/reporter"

module Tester
  class Context
    # Define the hooks that are run before or after tests
    # This will probably be refactored into the ContextHook class
    # to allow for more flexible hooks.
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

    def initialize(root, base)
      @root = root
      @base = base
    end
    
    # Find all files (not directories) in the context's directory
    # Ignore context hooks that run before or after tests
    def tests
      @tests ||= Dir.entries(@root).select { |e| File.file?(File.join(@root, e)) and not Context.hook?(e) }.map do |t|
        Tester::Test.new(File.join(@root, t), @base)
      end
    end
    
    # Find all directories in the context's directory
    # Ignore the directories "." and ".." to avoid infinite recursion
    def contexts
      @contexts ||= Dir.entries(@root).reject { |e| File.file?(File.join(@root, e)) or [".", ".."].include?(e) }.map do |c|
        Tester::Context.new(File.join(@root, c), @base)
      end
    end

    # Run a contexts tests and contexts
    # Something about this is not thread-safe
    def run!
      # Only run tests if the set-up passes
      if before.passed?
        # Run tests and report results
        run_tests!
        # Run the clean-up file, if present
        after.run!
      else
        # The set-up file failed, All tests in this context and sub-contexts cannot be run.
        set_no_run_reason! "Test set-up failed.\nFile: #{before.file}"
        # Report the results of tests
        report
      end
    end
    
    # Report test results to the user
    def report
      tests.each do |test|
        Tester::Reporter.report test.result
      end
      contexts.each do |context|
        context.report
      end
    end

    # Tests in this context and its contexts
    def all_tests
      # Explicit convesion to Array since the inject call on an empty array will return nil
      tests + Array(contexts.map(&:all_tests).inject(:+))
    end
    # Tests in this context and its contexts that failed 
    def failures
      all_tests.select(&:failed?)
    end
    # Tests in this context and its contexts that were skipped
    def skipped
      all_tests.select(&:skipped?)
    end
    # Tests in this context and its contexts that were not run
    def ignored
      all_tests.reject(&:ran?)
    end
    # Tests in this context and its contexts that were run
    def ran
      all_tests.select(&:ran?)
    end
    # Tests in this context and its contexts that passed
    def passed
      all_tests.select(&:passed?)
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
