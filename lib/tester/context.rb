require "tester/test"
require "tester/context_hook"
require "tester/reporter"

module Tester
  class Context
    
    # Define whether tests will run asynchronously
    def self.async=(bool)
      @@async = bool
    end
    
    def self.async?
      @@async
    end

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
    
    attr_reader :tests, :contexts

    def initialize(root, base, tests = nil, contexts = nil)
      @root = root
      @base = base
      @tests = tests || Context.tests(root, base)
      @contexts = contexts || Context.contexts(root, base)
    end

    # List of file types to ignore
    def self.excluded
      %w[*.c *.h]
    end

    def self.exclude?(file)
      excluded.any? do |exclude|
        file =~ Regexp.new(Regexp.escape(exclude).gsub('\*','.*?'))
      end
    end
    
    # Find all files (not directories) in the context's directory
    # Ignore context hooks that run before or after tests
    def self.tests(root, base)
      Dir.entries(root).select { |e| File.file?(File.join(root, e)) and not hook?(e) and not exclude?(e) }.map do |t|
        Tester::Test.new(File.join(root, t), base)
      end
    end
    
    # Find all directories in the context's directory
    # Ignore the directories "." and ".." to avoid infinite recursion
    def self.contexts(root, base)
      Dir.entries(root).reject { |e| File.file?(File.join(root, e)) or [".", ".."].include?(e) }.map do |c|
        Tester::Context.new(File.join(root, c), base)
      end
    end

    # Run a contexts tests and contexts
    # Something about this is not thread-safe
    def run!
      # Only run tests if the set-up passes
      if before.passed?
        # Run tests and report results
        new_context = if Context.async?
                        run_tests_async!
                      else
                        run_tests!
                      end
        # Run the clean-up file, if present
        after.run!
      else
        # The set-up file failed, All tests in this context and sub-contexts cannot be run.
        new_context = set_reason before.result, before.reason
        # Push the setup file to the 'stack trace'
        new_context = new_context.push before.file
        # Report the results of tests
        new_context.report
      end
      new_context
    end
    
    # Report test results to the user
    def report
      tests.each do |test|
        Tester::Reporter.report test
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
    
    def errored
      all_tests.select(&:errored?)
    end

    protected
    
    def set_reason(result, reason)
      new_tests = tests.map do |test|
        test.set_reason result, reason
      end
      new_contexts = contexts.map do |context|
        context.set_reason result, reason
      end
      Tester::Context.new(@root, @base, new_tests, new_contexts)
    end

    def push(file)
      new_tests = tests.map do |test|
        test.push file
      end
      new_contexts = contexts.map do |context|
        context.push file
      end
      Tester::Context.new(@root, @base, new_tests, new_contexts)
    end

    private
   
    def run_tests!
      # Run tests and contexts synchronously
      new_tests = tests.map do |test|
        new_test = test.run!
        Tester::Reporter.report new_test
        new_test
      end
      new_contexts = contexts.map do |context|
        context.run!
      end
      # Return a new context with these new tests and contexts to avoid mutation
      Tester::Context.new(@root, @base, new_tests, new_contexts)
    end
    def run_tests_async!
      # By avoiding mutation in the Test and Context objects, this is thread-safe
      # Create threads for each test and context, then join them all for a result

      # Create threads for tests
      new_test_threads = tests.map do |test|
        Thread.new do
          new_test = test.run!
          Tester::Reporter.report new_test
          new_test
        end
      end
      # Create threads for contexts
      new_context_threads = contexts.map do |context|
        Thread.new { context.run! }
      end
      # Wait for threads to finish, then get values
      new_tests = new_test_threads.map(&:join).map(&:value)
      new_contexts = new_context_threads.map(&:join).map(&:value)
      # Return a new context with these new tests and contexts to avoid mutation
      Tester::Context.new(@root, @base, new_tests, new_contexts)
    end

  end
end
