require 'helper'

require 'tmpdir'
require 'fileutils'

#
# End-to-end test the manbook
#
class TestManbook < Test::Unit::TestCase
  APP_SCRIPT = 'ruby bin/manbook'

  def setup
    @test_output_dir = Dir.mktmpdir('test_unit', '.')
  end

  def teardown
    FileUtils.remove_entry_secure(@test_output_dir)
  end

  def test_no_args
    status = Open4::popen4(app_script){|pid, stdin, stdout, stderr|
      assert_match(/ERROR: Which man page do you want to convert?/, stderr.read)
      assert(stdout.read.empty?)
    }
    assert_not_equal(0, status.exitstatus)
  end

  def test_existing_page_single
    status = Open4::popen4("#{app_script} ls"){|pid, stdin, stdout, stderr|
      assert(stderr.read.empty?)
      assert(stdout.read.empty?)
    }
    assert_equal(0, status.exitstatus)
  end

  def test_existing_page_multiple
    status = Open4::popen4("#{app_script} ls bash"){|pid, stdin, stdout, stderr|
      assert(stderr.read.empty?)
      assert(stdout.read.empty?)
    }
    assert_equal(0, status.exitstatus)
  end

private
  def app_script
    "#{APP_SCRIPT} --output #{@test_output_dir}"
  end
end
