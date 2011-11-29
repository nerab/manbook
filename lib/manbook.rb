$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'logger'
require 'active_support/core_ext/logger'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/attribute_accessors'

require 'manbook/errors'
require 'manbook/log_formatter'

module ManBook
  VERSION = File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION]))  
  mattr_accessor :logger
  
  unless @@logger
    @@logger = Logger.new(STDERR)
    @@logger.level = Logger::WARN
    @@logger.formatter = LogFormatter.new
  end
end
