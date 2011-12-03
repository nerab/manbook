require 'helper'

#
# End-to-end test the manbook
#
module ManBookTest
  class TestManbook < ManBookTest::TestCase
    APP_SCRIPT = 'ruby bin/manbook'

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

    def test_nonexisting_page_single
      status = Open4::popen4("#{app_script} foobar"){|pid, stdin, stdout, stderr|
        assert_match(/ERROR: No manual entry for foobar/, stderr.read)
        assert(stdout.read.empty?)
      }
      assert_not_equal(0, status.exitstatus)
    end

    def test_nonexisting_page_multiple
      pages = %w[foobar deadbeef]
      status = Open4::popen4("#{app_script} #{pages.join(' ')}"){|pid, stdin, stdout, stderr|
        catched_messages = pages.size
        stderr.read.each_line{|line|
          catched_messages -= 1 if /ERROR: No manual entry for .*/ =~ line
        }
        assert_equal(0, catched_messages)
        assert(stdout.read.empty?)
      }
      assert_not_equal(0, status.exitstatus)
    end

  private
    def app_script
      "#{APP_SCRIPT} --output #{output_dir}"
    end
  end
end