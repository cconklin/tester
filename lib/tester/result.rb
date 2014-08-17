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
        <<-END.unindent.rstrip
          #{name}:
            Failure Reason:
          #{reason.to_s.indent(2)}
            # #{file}
        END
      end
      def colored_epilogue  
        start = <<-END.unindent.red
          #{name}:
            Failure Reason:
          #{reason.to_s.indent(2)}
        END
        last = <<-END.unindent.blue
            # #{file}
        END
        start + last
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
        <<-END.unindent
          #{name}:
          #{reason.to_s.indent(1)}
            # #{file}
        END
      end
      def colored_epilogue
        "#{name}:".yellow +
        <<-END.unindent.rstrip.blue
          #{reason.to_s.indent(1)}
            # #{file}
        END
      end
    end
  end
end
