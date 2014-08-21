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
    options = {color: false, async: true}
    OptionParser.new do |opts|
      opts.banner = "Usage: tester.rb [options]"
      opts.on("-c", "--[no-]color", "Run with color") do |v|
        options[:color] = v
      end
      opts.on("--[no-]async", "Run tests asynchronously") do |a|
        options[:async] = a
      end
    end.parse!
    Tester::Reporter.colored = options[:color]
    Tester::Context.async = options[:async]
    Tester::Suite.new(ARGV).run!
  end
end

Tester.main
