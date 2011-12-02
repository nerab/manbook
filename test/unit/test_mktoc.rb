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

  def test_defaults
    status = Open4::popen4("#{app_script} #{@test_output_dir}"){|pid, stdin, stdout, stderr|
      assert_empty(stderr.read)
      assert_empty(stdout.read)
    }
    assert_equal(0, status.exitstatus)
    test_workproducts(ManBook::TITLE_DEFAULT)
  end

  def test_overridden_title
    title = "Foo42Bar"
    status = Open4::popen4("#{app_script} #{@test_output_dir} --title \"#{title}\""){|pid, stdin, stdout, stderr|
      assert_empty(stderr.read)
      assert_empty(stdout.read)
    }
    assert_equal(0, status.exitstatus)
    test_workproducts(title)
  end

private
  def test_workproducts(title)
    assert_equal(@fixtures.size + WORKPRODUCTS.size,
                 Dir.glob(File.join(@test_output_dir, '*')).size)

    WORKPRODUCTS.each{|k,v|
      assert(File.exist?(File.join(@test_output_dir, v)))

      # dispatch to test that is specific to the work product
      wp_test = WORK_PRODUCT_TESTS[k]
      raise "No test defined for work product #{k}" if wp_test.nil?
      send(wp_test, title)
    }
  end

  def assert_empty(str, msg = nil)
    assert(str.nil? || str.empty?, "Should have been empty, but was: #{str}")
  end

  def app_script
    "#{APP_SCRIPT}"
  end

  def work_product_test_html(title)
    doc = Nokogiri::HTML(File.read(File.join(@test_output_dir, 'index.html')))
    work_product_test(@fixtures, doc, '/html/body/ul/li', 'a/@href')
    assert_equal(title, doc.xpath('/html/head/title/text()').to_s)
    assert_equal(title, doc.xpath('/html/body/h1[1]/text()').to_s)
  end

  def work_product_test_ncx(title)
    doc = Nokogiri::XML(File.read(File.join(@test_output_dir, 'index.ncx')))
    work_product_test(@fixtures, doc, '/xmlns:ncx/xmlns:navMap/xmlns:navPoint', 'xmlns:content/@src')

    # TODO id and order
    # navPoint
    #   @id="bash.html"
    #   @playOrder="0"

    # TODO title
    # <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
    #   <head>
    #     <meta name="dtb:title" content="Overridden from commandline"/>
    #   </head>
    #   <docTitle><text>Overridden from commandline</text></docTitle>
  end

  def work_product_test_opf(title)
    doc = Nokogiri::XML(File.read(File.join(@test_output_dir, 'index.opf')))

    # the opf must include links to index.html and index.ncx
    work_product_test(['index.html', 'index.ncx'].concat(@fixtures),
                      doc,
                      '//xmlns:manifest/xmlns:item',
                      '@href')

    # cross-references within the document
    work_product_test(['toc'].concat(@fixtures),
                      doc,
                      '//xmlns:spine/xmlns:itemref',
                      '@idref')

    # TODO title
    # <package version="2.0" xmlns="http://www.idpf.org/2007/opf" unique-identifier="uid">
    #   <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    #     <dc:title>Overridden from commandline</dc:title>
    #     <dc:language>en</dc:language>
    #     <dc:identifier id="uid">Overridden from commandline</dc:identifier>
  end

  def work_product_test(fixtures, doc, xpath_list, xpath_href)
    assert_not_nil(doc)

    list = doc.xpath(xpath_list)
    assert_not_nil(list)

    # every fixture file should be listed
    assert_equal(fixtures.size, list.size)

    hrefs = list.map{|li| li.xpath(xpath_href).to_s}
    assert_not_nil(hrefs)

    # each work product must be linked
    fixtures.each{|fixture|
      assert(hrefs.include?(fixture), "Could not find '#{fixture}' in #{hrefs.inspect}")
    }

    # each link must point to a work product
    hrefs.each{|li|
      assert(fixtures.include?(li), "Could not find '#{li}' in #{fixtures.inspect}")
    }
  end
end
