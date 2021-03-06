$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'logger'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/attribute_accessors'
require 'open4'
require 'nokogiri'

require 'manbook/formatter'
require 'manbook/html_formatter'
require 'manbook/parser'
require 'manbook/page'

require 'manbook/errors'
require 'manbook/log_formatter'

module ManBook
  VERSION = File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION])).chomp
  TITLE_DEFAULT       = 'ManBook - a book of selected man pages'
  AUTHOR_DEFAULT      = 'Multiple Authors'
  COVER_IMAGE_DEFAULT = File.join(File.dirname(__FILE__), '..', 'templates', 'library_books.jpg')
  ORDER_DEFAULT       = :title

  mattr_accessor :logger

  unless @@logger
    @@logger = Logger.new(STDERR)
    @@logger.level = Logger::WARN
    @@logger.formatter = LogFormatter.new
  end
end
