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
  WORKPRODUCTS = {:html => 'index.html', :ncx => 'index.ncx', :opf => 'index.opf'}

  #
  # which method tests which work product
  #
  WORK_PRODUCT_TESTS = {:html => 'work_product_test_html', :ncx => 'work_product_test_ncx', :opf => 'work_product_test_opf'}

  def setup
    @test_output_dir = Dir.mktmpdir('test_unit_', '.')
    FileUtils.cp_r(File.join(FIXTURES_DIR, '.'), @test_output_dir)
    @fixtures = Dir.glob(File.join(FIXTURES_DIR, '*')).map{|f| File.basename(f)}
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
    assert_equal(@fixtures.size + WORKPRODUCTS.size,
                 Dir.glob(File.join(@test_output_dir, '*')).size)

    WORKPRODUCTS.each{|k,v|
      assert(File.exist?(File.join(@test_output_dir, v)))

      # dispatch to test that is specific to the work product
      wp_test = WORK_PRODUCT_TESTS[k]
      raise "No test defined for work product #{k}" if wp_test.nil?
      send(wp_test)
    }
  end

  def test_overridden_title
    # TODO
  end

private
  def assert_empty(str, msg = nil)
    assert(str.nil? || str.empty?, "Should have been empty, but was: #{str}")
  end

  def app_script
    "#{APP_SCRIPT}"
  end

  def work_product_test_html
    doc = Nokogiri::HTML(File.read(File.join(@test_output_dir, 'index.html')))
    assert_not_nil(doc)

    list = doc.xpath('/html/body/ul/li')
    assert_not_nil(list)

    # every fixture file should be listed
    assert_equal(@fixtures.size, list.size)

    hrefs = list.map{|li| li.xpath('a/@href').to_s}
    assert_not_nil(hrefs)

    # each work product must be linked
    @fixtures.each{|fixture|
      assert(hrefs.include?(fixture))
    }

    # each link must point to a work product
    hrefs.each{|li|
      assert(@fixtures.include?(li))
    }
  end

  def work_product_test_ncx
    # TODO
  end

  def work_product_test_opf
    # TODO
  end
end
