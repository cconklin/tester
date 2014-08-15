module Tester
  class Test
    # Sentinel Object for tests that cannot be executed
    class NotExecutable < Exception; end
    # Test Results
    class NoResult; end
    class Pass; end
    class Fail; end
    class Skip; end

    attr_reader :file, :result, :reason
    def initialize(file)
      @file = file
      @result = NoResult
      unless File.executable? @file
        raise NotExecutable
      end
    end
    
    def name
      file.gsub /[_\/]/, " "
    end

    def ran?
      @result != NoResult
    end

    def run!
      @reason = %x[#{file}] # Run the test file
      # Capture the exit status, and map to a result object
      @result = case $?.exitstatus
      when 0; Pass
      when 1; Fail
      when 2; Skip
      end
    end

    def passed?
      @result == Pass
    end
    def failed?
      @result == Fail
    end
    def skipped?
      @result == Skip
    end
  end
end
