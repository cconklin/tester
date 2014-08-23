module Tester
  module Refinements
    module String
      refine ::String do
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
        {
          red: 31,
          green: 32,
          yellow: 33,
          blue: 34,
          magenta: 35,
          cyan: 36,
          default: 39
        }.each do |color, code|
          define_method color do
            "\33[#{code}m#{self}\33[0m"
          end
          define_method "bright_#{color}" do
            "\33[1;#{code}m#{self}\33[0m"
          end
        end
        def color(color)
          eval("self.#{color}")
        end
      end
    end
  end
end
