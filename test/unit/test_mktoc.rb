require 'helper'

require 'tmpdir'
require 'fileutils'

#
# End-to-end test for mktoc
#
module ManBookTest
  class TestMkToc < ManBookTest::TestCase
    #
    # command under test
    #
    APP_SCRIPT = 'ruby bin/mktoc'

    #
    # generator identification
    #
    GENERATOR = "mktoc v#{ManBook::VERSION}"

    #
    # generated work products (in addition to HTML input files that were created externally)
    #
    WORKPRODUCTS = {:html  => 'index.html',
                    :ncx   => 'index.ncx',
                    :opf   => 'index.opf',
                    :about => 'about.html',
                    :cover => 'library_books.jpg'}

    #
    # which method tests what work product
    #
    WORK_PRODUCT_TESTS = {:html  => 'assert_workproduct_html',
                          :ncx   => 'assert_workproduct_ncx',
                          :opf   => 'assert_workproduct_opf',
                          :about => 'assert_workproduct_about',
                          :cover => 'assert_workproduct_cover'}

    def setup
      super
      FileUtils.cp_r(File.join(FIXTURES_DIR, '.'), output_dir)
      @fixtures = Dir.glob(File.join(FIXTURES_DIR, '*')).map{|f| File.basename(f)}
    end

    def test_no_args
      status = Open4::popen4(app_script){|pid, stdin, stdout, stderr|
        assert_match(/ERROR: Directory argument missing/, stderr.read)
        assert_empty(stdout.read)
      }
      assert_not_equal(0, status.exitstatus)
    end

    def test_defaults
      status = Open4::popen4("#{app_script} #{output_dir}"){|pid, stdin, stdout, stderr|
        assert_empty(stderr.read)
        assert_empty(stdout.read)
      }
      assert_equal(0, status.exitstatus)
      assert_all_workproducts(ManBook::TITLE_DEFAULT, File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_overridden_title
      title = "Foo42Bar"
      status = Open4::popen4("#{app_script} #{output_dir} --title \"#{title}\""){|pid, stdin, stdout, stderr|
        assert_empty(stderr.read)
        assert_empty(stdout.read)
      }
      assert_equal(0, status.exitstatus)
      assert_all_workproducts(title, File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_no_cover_image
      # TODO
    end

    def test_alt_cover_image
      # TODO
    end

    def test_alt_cover_image_not_found
      # TODO
    end

  private
    def assert_all_workproducts(title, cover_image = nil)
      assert_equal(@fixtures.size + WORKPRODUCTS.size, Dir.glob(File.join(output_dir, '*')).size)

      WORKPRODUCTS.each{|k,v|
        assert(File.exist?(File.join(output_dir, v)))

        # dispatch to test that is specific to the work product
        wp_test = WORK_PRODUCT_TESTS[k]
        raise "No test defined for work product #{k}" if wp_test.nil?
        send(wp_test, title, cover_image)
      }
    end

    def assert_empty(str, msg = nil)
      assert(str.nil? || str.empty?, "Should have been empty, but was: #{str}")
    end

    def app_script
      "#{APP_SCRIPT}"
    end

    def assert_workproduct_html(title, cover_image = nil)
      doc = Nokogiri::HTML(File.read(File.join(output_dir, 'index.html')))
      assert_workproduct(['about.html'].concat(@fixtures), doc, '/html/body/ul/li', 'a/@href')

      # index.html does not use the book title, but "Table Of Contents"
      assert_equal("Table Of Contents", doc.xpath('/html/head/title/text()').to_s)
      assert_equal("Table Of Contents", doc.xpath('/html/body/h1[1]/text()').to_s)

      assert_equal(GENERATOR, doc.xpath("/html/head/meta[@name='generator']/@content").to_s)
      assert_equal("About this book", doc.xpath('/html/body/ul/li[1]/a/text()').to_s)
    end

    def assert_workproduct_ncx(title, cover_image = nil)
      doc = Nokogiri::XML(File.read(File.join(output_dir, 'index.ncx')))

      fixtures = ['about.html'].concat(@fixtures)
      fixtures << cover_image unless cover_image.nil?
      assert_workproduct(fixtures, doc, '/xmlns:ncx/xmlns:navMap/xmlns:navPoint', 'xmlns:content/@src')

      assert_equal(title, doc.xpath("/xmlns:ncx/xmlns:head/xmlns:meta[@name='dtb:title']/@content").to_s)
      assert_equal(title, doc.xpath("/xmlns:ncx/xmlns:docTitle/xmlns:text/text()").to_s)
      assert_equal(GENERATOR, doc.xpath("/xmlns:ncx/xmlns:head/xmlns:meta[@name='dtb:generator']/@content").to_s)

      # TODO id and order
      # navPoint
      #   @id="bash.html"
      #   @playOrder="0"
    end

    def assert_workproduct_opf(title, cover_image = nil)
      doc = Nokogiri::XML(File.read(File.join(output_dir, 'index.opf')))

      # the opf must include links to index.html and index.ncx
      item_fixtures = ['index.html', 'index.ncx', 'about.html'].concat(@fixtures)
      item_fixtures << cover_image unless cover_image.nil?
      assert_workproduct(item_fixtures, doc, '//xmlns:manifest/xmlns:item', '@href')

      # cross-references within the document
      xref_fixtures = ['toc', 'about.html'].concat(@fixtures)
      xref_fixtures << 'cover-image' unless cover_image.nil?
      assert_workproduct(xref_fixtures, doc, '//xmlns:spine/xmlns:itemref', '@idref')

      assert_equal(title, doc.xpath('/xmlns:package/xmlns:metadata/dc:title/text()',
                                    {'dc' => "http://purl.org/dc/elements/1.1/",
                                     'xmlns' => 'http://www.idpf.org/2007/opf'}).to_s)

      assert_equal(GENERATOR, doc.xpath('/xmlns:package/xmlns:metadata/dc:generator/text()',
                                       {'dc' => "http://purl.org/dc/elements/1.1/",
                                        'xmlns' => 'http://www.idpf.org/2007/opf'}).first.to_s)

      # reference to cover image in meta data. The other two references were already tested above
      unless cover_image.nil?
        assert_equal('cover-image', doc.xpath("/xmlns:package/xmlns:metadata/xmlns:meta[@name='cover']/@content").to_s)
      end
    end

    def assert_workproduct_about(title, cover_image = nil)
      # no further tests
    end

    def assert_workproduct_cover(title, cover_image = nil)
      # no further tests
    end

    def assert_workproduct(fixtures, doc, xpath_list, xpath_href)
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
end
