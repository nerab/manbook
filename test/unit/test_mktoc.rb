require 'helper'

require 'tmpdir'
require 'fileutils'

#
# End-to-end for mktoc
#
class TestMkToc < Test::Unit::TestCase
  #
  # command under test
  #
  APP_SCRIPT = 'ruby bin/mktoc'
  
  #
  # expected work products
  #
  WORKPRODUCTS = ['index.html', 'index.ncx', 'index.opf']
  
  def setup
    @test_output_dir = Dir.mktmpdir('test_unit', '.')
    FileUtils.cp_r(File.join(FIXTURES_DIR, '.'), @test_output_dir)
  end

  def teardown
    FileUtils.remove_entry_secure(@test_output_dir)
  end

  def test_no_args
    status = Open4::popen4(app_script){|pid, stdin, stdout, stderr|
      assert_match(/ERROR: Directory argument missing/, stderr.read)
      assert_empty(stdout.read)
    }
    assert_not_equal(0, status.exitstatus)
  end

  def test_plain
    status = Open4::popen4("#{app_script} #{@test_output_dir}"){|pid, stdin, stdout, stderr|
      assert_empty(stderr.read)
      assert_empty(stdout.read)
    }
    assert_equal(0, status.exitstatus)
    assert_equal(Dir.glob(File.join(FIXTURES_DIR, '*')).size + WORKPRODUCTS.size, 
                 Dir.glob(File.join(@test_output_dir, '*')).size)
    
    WORKPRODUCTS.each{|wp|
      assert(File.exist?(File.join(@test_output_dir, wp)))
    }
    
    
  end
  
private
  def assert_empty(str, msg = nil)
    assert(str.nil? || str.empty?, "Should have been empty, but was: #{str}")
  end

  def app_script
    "#{APP_SCRIPT}"
  end
end
