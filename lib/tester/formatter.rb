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
      define_method meth do |symbol, color: :default|
        @symbols[result] = symbol
        @colors[result] = color
      end
    end
    # Accessor methods for the symbol and color
    def symbol(result)
      @symbols[result]
    end
    def color(result)
      @colors[result]
    end

    def colored?
      @colored
    end

    def formatted_symbol(result)
      if colored?
        # Get the color of the result, apply it to the symbol
        symbol(result).color(color(result))
      else
        symbol(result)
      end
    end
    
    def display(result)
      if colored?
        "#{result.name}:".color(color(result.class)) << "\n" <<
        "#{result.reason}".strip.color(color(result.class)).indent(2) << "\n" <<
        "# #{result.file}".indent.color(:blue)
      else
        "#{result.name}:" << "\n" <<
        "#{result.reason}".strip.indent(2) << "\n" <<
        "# #{result.file}".indent
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
