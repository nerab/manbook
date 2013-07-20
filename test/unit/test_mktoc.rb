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
                    :about => 'about.html'}

    #
    # which method tests what work product
    #
    WORK_PRODUCT_TESTS = {:html  => 'test_workproduct_html',
                          :ncx   => 'test_workproduct_ncx',
                          :opf   => 'test_workproduct_opf',
                          :about => 'test_workproduct_about',
                          :cover => 'test_workproduct_cover'}

    def setup
      super
      FileUtils.cp_r(File.join(FIXTURES_DIR, '.'), output_dir)
      @fixtures = Dir.glob(File.join(FIXTURES_DIR, '*.html')).map{|f| File.basename(f)}
    end

    def test_no_args
      assert_exec("#{app_script}", false, nil, /ERROR: Directory argument missing/)
    end

    def test_defaults
      assert_exec("#{app_script} #{output_dir}")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_overridden_title
      title = "Foo42Bar"
      assert_exec("#{app_script} #{output_dir} --title \"#{title}\"")
      test_all_workproducts(title, ManBook::AUTHOR_DEFAULT, File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_overridden_author
      author = "James Born"
      assert_exec("#{app_script} #{output_dir} --author \"#{author}\"")
      test_all_workproducts(ManBook::TITLE_DEFAULT, author, File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end
    
    def test_overridden_title_and_author
      title = "Foo42Bar42"
      author = "James F. Born"
      assert_exec("#{app_script} #{output_dir} --title \"#{title}\" --author \"#{author}\"")
      test_all_workproducts(title, author, File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_no_cover_image
      assert_exec("#{app_script} #{output_dir} --no-cover-image")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, nil)
    end

    def test_alt_cover_image
      cover_image = ManBook::COVER_IMAGE_DEFAULT
      assert(File.exist?(cover_image))
      assert_exec("#{app_script} #{output_dir} --cover-image #{cover_image}")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, File.basename(cover_image))
    end

    def test_alt_cover_image_not_found
      cover_image = "DOES_NOT_EXIST"
      assert(!File.exist?(cover_image))
      assert_exec("#{app_script} #{output_dir} --cover-image #{cover_image}", false, nil, /ERROR: Could not find cover image/)
    end

  private
    def test_all_workproducts(title, author, cover_image = nil)
      if cover_image.nil?
        workproducts = WORKPRODUCTS
      else
        workproducts = WORKPRODUCTS.merge({:cover => 'library_books.jpg'})
      end

      assert_equal(@fixtures.size + workproducts.size, Dir.glob(File.join(output_dir, '*')).size)

      workproducts.each{|k,v|
        vf = File.join(output_dir, v)
        assert(File.exist?(vf), "Expect #{vf} to exist")

        # dispatch to test that is specific to the work product
        wp_test = WORK_PRODUCT_TESTS[k]
        raise "No test defined for work product #{k}" if wp_test.nil?
        send(wp_test, title, cover_image)
      }
    end

    def assert_exec(cmd, assert_status_success = true, re_stdout = nil, re_stderr = nil)
      status = Open4::popen4(cmd){|pid, stdin, stdout, stderr|
        if re_stdout.nil?
          assert_empty(stdout.read)
        else
          assert_match(re_stdout, stdout.read)
        end

        if re_stderr.nil?
          assert_empty(stderr.read)
        else
          assert_match(re_stderr, stderr.read)
        end
      }

      if assert_status_success
        assert_equal(0, status.exitstatus)
      else
        assert_not_equal(0, status.exitstatus)
      end
    end

    def assert_empty(str, msg = nil)
      assert(str.nil? || str.empty?, "Should have been empty, but was: #{str}")
    end

    def app_script
      "#{APP_SCRIPT}"
    end

    def test_workproduct_html(title, author, cover_image = nil)
      doc = Nokogiri::HTML(File.read(File.join(output_dir, 'index.html')))
      assert_workproduct(['about.html'].concat(@fixtures), doc, '/html/body/ul/li', 'a/@href')

      # index.html does not use the book title, but "Table Of Contents"
      assert_equal("Table Of Contents", doc.xpath('/html/head/title/text()').to_s)
      assert_equal("Table Of Contents", doc.xpath('/html/body/h1[1]/text()').to_s)

      assert_equal(GENERATOR, doc.xpath("/html/head/meta[@name='generator']/@content").to_s)
      assert_equal("About this book", doc.xpath('/html/body/ul/li[1]/a/text()').to_s)
    end

    def test_workproduct_ncx(title, author, cover_image = nil)
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

    def test_workproduct_opf(title, author, cover_image = nil)
      doc = Nokogiri::XML(File.read(File.join(output_dir, 'index.opf')))

      # the opf must include links to index.html and index.ncx
      item_fixtures = ['index.html', 'index.ncx', 'about.html'].concat(@fixtures)
      item_fixtures << cover_image unless cover_image.nil?
      assert_workproduct(item_fixtures, doc, '//xmlns:manifest/xmlns:item', '@href')

      # cross-references within the document
      xref_fixtures = ['index', 'about.html'].concat(@fixtures)
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

    def test_workproduct_about(title, author, cover_image = nil)
      # no further tests
    end

    def test_workproduct_cover(title, author, cover_image = nil)
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
