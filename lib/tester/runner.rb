require "open3"

module Tester
  class Runner
    class NotExecutable
      # Since NotExecutable is the reason passed when a test cannot be run,
      # it needs to be able to be represented as a human readable reason.
      def self.to_s
        "The file was not executable"
      end
    end
    attr_reader :stdout, :stderr, :exitstatus
    def initialize(out, err, pid)
      @stdout = out
      @stderr = err
      @exitstatus = pid.exitstatus
    end
    def self.run(command)
      result = begin
                 # returns [stdout, stderr, pid]
                 Open3.capture3(command)
               rescue Errno::ENOENT, Errno::EACCES
                 # The file cannot be executed, or does not exist
                 # In this case, set the stdout and stderr to NotExecutable,
                 # which behaves like a string when needed; also create a dummy
                 # pid with a nil exitstatus
                 [NotExecutable, NotExecutable, Struct.new(:exitstatus).new(nil)]
               end
      new(*result)
    end
  end
end
