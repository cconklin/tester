require "tester/result"
require "tester/refinements/string"

module Tester
  class Formatter
    # Use String monkey-patches for colors
    using Tester::Refinements::String

    attr_reader :name, :inline
    attr_writer :colored
    def initialize(name, inline: true)
      @name = name
      @inline = inline
      @symbols = {}
      @colors = {}
      @colored = false
    end
    # Define the DSL methods for pass, fail, etc.
    {
      pass: Tester::Result::Pass,
      fail: Tester::Result::Fail,
      skip: Tester::Result::Skip,
      ignore: Tester::Result::NoResult
    }.each do |meth, result|
      define_method meth do |symbol = nil, color: :default, &block|
        raise ArgumentError if not (symbol or block)
        if block
          raise ArgumentError if symbol
          @symbols[result] = block
        else
          @symbols[result] = ->(test) { symbol }
        end
        @colors[result] = color
      end
    end
    # Accessor methods for the symbol and color
    def symbol(test)
      @symbols[test.result].call(test)
    end
    def color(result)
      @colors[result]
    end

    def colored?
      @colored
    end

    def formatted_symbol(test)
      if colored?
        # Get the color of the result, apply it to the symbol
        symbol(test).color(color(test.result))
      else
        symbol(test)
      end
    end
    
    def display(test)
      if colored?
        "#{test.name}:".color(color(test.result)) << "\n" <<
        "#{test.reason}".strip.color(color(test.result)).indent(2) << "\n" <<
        "# #{test.file}".indent.color(:blue)
      else
        "#{test.name}:" << "\n" <<
        "#{test.reason}".strip.indent(2) << "\n" <<
        "# #{test.file}".indent
      end
    end

    # Class Methods
    def self.define_format(name, **kwargs, &block)
      @formatters = {}
      @formatters[name] = new(name, **kwargs)
      @formatters[name].instance_eval &block
    end

    def self.formatter(name)
      @formatters[name]
    end

  end
end
