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
  end
end
