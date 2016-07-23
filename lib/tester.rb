$: << File.expand_path(File.dirname(__FILE__))
require "tester/suite"
require "tester/context"
require "tester/test"
require "tester/context_hook"
require "tester/reporter"
require "tester/result"
require 'optparse'

module Tester
  def self.main
    options = {
      color: true,
      async: true,
      formatter: "default"
    }
    formatters = Dir.entries(File.expand_path(File.join(File.dirname(__FILE__), "tester", "formatters"))).map {|f| File.basename(f)[0..-4]}.reject(&:empty?)
    OptionParser.new do |opts|
      opts.banner = "Usage: tester.rb [options]"
      opts.on("--[no-]color", "Run with color") do |v|
        options[:color] = v
      end
      opts.on("--[no-]async", "Run tests asynchronously") do |a|
        options[:async] = a
      end
      opts.on("--format FORMAT", formatters, "Use formatter FORMAT") do |formatter|
        options[:formatter] = formatter
      end
    end.parse!
    require "tester/formatters/#{options[:formatter]}"
    formatter = Tester::Formatter.formatter(options[:formatter])
    formatter.colored = options[:color]
    reporter = Tester::Reporter.new formatter
    Tester::Context.reporter = reporter
    Tester::Context.async = options[:async]
    Tester::Suite.new(ARGV, reporter).run!
  end
end

Tester.main
