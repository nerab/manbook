require 'rubygems'
require 'bundler'
require 'tmpdir'
require 'fileutils'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'manbook'

class Test::Unit::TestCase
  FIXTURES_DIR = File.join(File.dirname(__FILE__), 'fixtures')
end

module ManBookTest
  class TestCase < Test::Unit::TestCase
    attr_reader :output_dir

    def setup
      @output_dir = Dir.mktmpdir(File.join('test', 'tmp', 'unit-test'), '.')
    end

    def teardown
      FileUtils.remove_entry_secure(@output_dir)
    end

    # solves the problem of non-existing test cases
    # for alternatives, see http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/76191
    def test_output_dir
      assert(File.exist?(@output_dir))
    end
  end
end
