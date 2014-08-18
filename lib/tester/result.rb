module Tester
  module Result
    
    module StringRefinement
      refine String do
        # Strip leading whitespace from each line that is the same as the 
        # amount of whitespace on the first line of the string.
        # Leaves _additional_ indentation on later lines intact.
        def unindent
          gsub /^#{self[/\A\s*/]}/, ''
        end
        def indent(amount=1)
          split("\n").map do |line|
            "  " * amount + line
          end.join("\n")
        end
        def red
          "\33[31m#{self}\33[0m"
        end
        def green
          "\33[32m#{self}\33[0m"
        end
        def yellow
          "\33[33m#{self}\33[0m"
        end
        def blue
          "\33[34m#{self}\33[0m"
        end
      end
    end

    using StringRefinement

    class Base
      attr_reader :name, :reason, :file
      def initialize(name, reason, file)
        @name = name
        @reason = reason
        @file = file
      end
      def epilogue
        ""
      end
      def colored_epilogue
        epilogue
      end
    end
    class NoResult < Base
      def self.icon
        "?"
      end
      def self.colored_icon
        icon
      end
    end
    class Pass < Base
      def self.icon
        "."
      end
      def self.colored_icon
        icon.green
      end
    end
    class Fail < Base
      def epilogue
        "#{name}:" << "\n" <<
        "Failure Reason:".indent << "\n" <<
        "#{reason}".indent(2) << "\n" <<
        "# #{file}".indent
      end
      def colored_epilogue  
        "#{name}:".red << "\n" <<
        "Failure Reason:".indent.red << "\n" <<
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
    class Skip < Base
      def self.icon
        "*"
      end
      def self.colored_icon
        icon.yellow
      end
      def epilogue
        "#{name}:" << "\n" <<
        "Reason:".indent << "\n" <<
        "#{reason}".indent(2) << "\n" <<
        "# #{file}".indent
      end
      def colored_epilogue
        "#{name}:".yellow << "\n" <<
        "Reason:".indent.yellow << "\n" <<
        "#{reason}".indent(2).yellow << "\n" <<
        "# #{file}".indent.blue
      end
    end
  end
end
