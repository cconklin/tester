require "tester/refinements/string"
module Tester
  module Result
    
    # use the string refinement which adds ANSI colors
    using Tester::Refinements::String

    class Base
      attr_reader :name, :reason, :file
      def initialize(name, reason, file)
        @name = name
        @reason = reason
        @file = file
      end
      def epilogue
        "#{name}:" << "\n" <<
        "#{reason}".indent(2) << "\n" <<
        "# #{file}".indent
      end
      def colored_epilogue
        "#{name}:" << "\n" <<
        "#{reason}".indent(2) << "\n" <<
        "# #{file}".indent.blue
      end
    end
    
    # For tests that did not run
    class NoResult < Base
      def self.icon
        "?"
      end
      def self.colored_icon
        icon
      end
    end

    # For tests that passed
    class Pass < Base
      def self.icon
        "."
      end
      def self.colored_icon
        icon.green
      end
    end

    # For tests that failed
    class Fail < Base
      def colored_epilogue  
        "#{name}:".red << "\n" <<
        "#{reason}".indent(2).red << "\n" <<
        "# #{file}".indent.blue
      end
      def self.icon
        "F"
      end
      def self.colored_icon
        icon.red
      end
    end

    # For tests that were skipped
    class Skip < Base
      def self.icon
        "*"
      end
      def self.colored_icon
        icon.yellow
      end
      def colored_epilogue
        "#{name}:".yellow << "\n" <<
        "#{reason}".indent(2).yellow << "\n" <<
        "# #{file}".indent.blue
      end
    end
  end
end
