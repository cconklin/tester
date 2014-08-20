require "open3"

module Tester
  class Runner
    class NotExecutable
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
                 Open3.capture3(command)
               rescue Errno::ENOENT
                 [NotExecutable, NotExecutable, Struct.new(:exitstatus).new(nil)]
               end
      new(*result)
    end
  end
end
