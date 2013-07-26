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
    APP_SCRIPT = 'bin/mktoc'

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

    COVER_IMAGE_ALT = File.join(FIXTURES_DIR, 'alt-cover.jpg')

    SPECIAL_TITLE_FIXTURES = ['about.html', 'bash.html', 'git.html', 'gunzip.html', 'less.html', 'man.html']

    def setup
      super
      fixtures = Dir.glob(File.join(FIXTURES_DIR, '*.html'))
      FileUtils.cp_r(fixtures, output_dir)
      @fixtures = fixtures.map{|f| File.basename(f)}
    end

    def test_no_args
      assert_exec("#{app_script}", false, nil, /ERROR: Directory argument missing/)
    end

    def test_defaults
      assert_exec("#{app_script} #{output_dir}")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, :cover_image => File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_overridden_title
      title = "Foo42Bar"
      assert_exec("#{app_script} #{output_dir} --title \"#{title}\"")
      test_all_workproducts(title, ManBook::AUTHOR_DEFAULT, :cover_image => File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_overridden_author
      author = "James Born"
      assert_exec("#{app_script} #{output_dir} --author \"#{author}\"")
      test_all_workproducts(ManBook::TITLE_DEFAULT, author, :cover_image => File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_overridden_title_and_author
      title = "Foo42Bar42"
      author = "James F. Born"
      assert_exec("#{app_script} #{output_dir} --title \"#{title}\" --author \"#{author}\"")
      test_all_workproducts(title, author, :cover_image => File.basename(ManBook::COVER_IMAGE_DEFAULT))
    end

    def test_no_cover_image
      assert_exec("#{app_script} #{output_dir} --no-cover-image")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT)
    end

    def test_order_by_title
      assert_exec("#{app_script} #{output_dir} --no-cover-image --sort-by=title")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, :order => :title)
    end

    def test_order_by_author
      assert_exec("#{app_script} #{output_dir} --no-cover-image --sort-by=author")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, :order => :author)
    end

# TODO Enable once Page is working
    # def test_order_by_unknown_attribute
    #   order = "DOES_NOT_EXIST"
    #   assert_exec("#{app_script} #{output_dir} --no-cover-image --sort-by=#{order}", false, nil, /ERROR: #{order} is not a valid sort order attribute/)
    # end

    def test_alt_cover_image
      cover_image = COVER_IMAGE_ALT
      assert(File.exist?(cover_image))
      assert_exec("#{app_script} #{output_dir} --cover-image #{cover_image}")
      test_all_workproducts(ManBook::TITLE_DEFAULT, ManBook::AUTHOR_DEFAULT, :cover_image => File.basename(cover_image))
    end

    def test_alt_cover_image_not_found
      cover_image = "DOES_NOT_EXIST"
      assert(!File.exist?(cover_image))
      assert_exec("#{app_script} #{output_dir} --cover-image #{cover_image}", false, nil, /ERROR: Could not find cover image/)
    end

  private
    def test_all_workproducts(title, author, options = {})
      options.reverse_merge!({:cover_image => nil, :order => ManBook::ORDER_DEFAULT})

      if options[:cover_image].nil?
        workproducts = WORKPRODUCTS
      else
        workproducts = WORKPRODUCTS.merge({:cover => options[:cover_image]})
      end

      expected = @fixtures + workproducts.values
      actual = Dir.glob(File.join(output_dir, '*')).map{|f| File.basename(f)}
      assert_equal((expected - actual), (actual - expected))

      workproducts.each{|k,v|
        vf = File.join(output_dir, v)
        assert(File.exist?(vf), "Expect #{vf} to exist")

        # dispatch to test that is specific to the work product
        wp_test = WORK_PRODUCT_TESTS[k]
        raise "No test defined for work product #{k}" if wp_test.nil?
        send(wp_test, title, author, options)
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

    def test_workproduct_html(title, author, options)
      options.reverse_merge!({:cover_image => nil, :order => ManBook::ORDER_DEFAULT})

      doc = Nokogiri::HTML(File.read(File.join(output_dir, 'index.html')))

      assert_workproduct(@fixtures, doc, '/html/body/ul/li', 'a/@href')

      # index.html does not use the book title, but "Table Of Contents"
      assert_equal("Table Of Contents", doc.xpath('/html/head/title/text()').to_s)
      assert_equal("Table Of Contents", doc.xpath('/html/body/h1[1]/text()').to_s)

      assert_equal(GENERATOR, doc.xpath("/html/head/meta[@name='generator']/@content").to_s)
      assert_equal("About this book", doc.xpath('/html/body/ul/li[1]/a/text()').to_s)

      sorted_pages = pages.sort{|l,r| l[options[:order]] <=> r[options[:order]]}

      # Test href in content and in order
      expected_files = sorted_pages.map{|p| p[:file_name]}
      actual_files   = doc.xpath('/html/body/ul/li/a/@href').map{|a| a.value}
      assert_equal(expected_files, actual_files)

      # Test titles in content and in order
      expected_titles = sorted_pages.map{|p| p[:title].upcase}
      actual_titles   = doc.xpath("/html/body/ul/li").map{|li| li.inner_text.upcase}
      assert_equal(expected_titles, actual_titles)
    end

    def test_workproduct_ncx(title, author, options)
      options.reverse_merge!({:cover_image => nil, :order => ManBook::ORDER_DEFAULT})

      doc = Nokogiri::XML(File.read(File.join(output_dir, 'index.ncx')))

      @fixtures << options[:cover_image] unless options[:cover_image].nil?
      assert_workproduct(@fixtures, doc, '/xmlns:ncx/xmlns:navMap/xmlns:navPoint', 'xmlns:content/@src')

      assert_equal(title, doc.xpath("/xmlns:ncx/xmlns:head/xmlns:meta[@name='dtb:title']/@content").to_s)
      assert_equal(title, doc.xpath("/xmlns:ncx/xmlns:docTitle/xmlns:text/text()").to_s)
      assert_equal(GENERATOR, doc.xpath("/xmlns:ncx/xmlns:head/xmlns:meta[@name='dtb:generator']/@content").to_s)

      # TODO id and order of members as specified in playOrder
      # navPoint
      #   @id="bash.html"
      #   @playOrder="0"
    end

    def test_workproduct_opf(title, author, options)
      options.reverse_merge!({:cover_image => nil, :order => ManBook::ORDER_DEFAULT})
      doc = Nokogiri::XML(File.read(File.join(output_dir, 'index.opf')))

      # the opf must include links to index.html and index.ncx
      item_fixtures = ['index.html', 'index.ncx'].concat(@fixtures)
      assert_workproduct(item_fixtures, doc, '//xmlns:manifest/xmlns:item', '@href')

      # cross-references within the document, but only include *.html fixtures
      xref_fixtures = ['index'].concat(@fixtures.select{|f| f.match(/.*\.html/)})
      xref_fixtures << 'cover-image' unless options[:cover_image].nil?
      assert_workproduct(xref_fixtures, doc, '//xmlns:spine/xmlns:itemref', '@idref')

      assert_equal(title, doc.xpath('/xmlns:package/xmlns:metadata/dc:title/text()',
                                    {'dc' => "http://purl.org/dc/elements/1.1/",
                                     'xmlns' => 'http://www.idpf.org/2007/opf'}).to_s)

      assert_equal(GENERATOR, doc.xpath('/xmlns:package/xmlns:metadata/dc:generator/text()',
                                       {'dc' => "http://purl.org/dc/elements/1.1/",
                                        'xmlns' => 'http://www.idpf.org/2007/opf'}).first.to_s)

      # reference to cover image in meta data. The other two references were already tested above
      unless options[:cover_image].nil?
        assert_equal('cover-image', doc.xpath("/xmlns:package/xmlns:metadata/xmlns:meta[@name='cover']/@content").to_s)
      end

      # TODO id and href. Order does not matter.
      # <item id="less.html" href="less.html" media-type="text/html" />

      # TODO Assert than members present in the manifest are also present in the spine
    end

    def test_workproduct_about(title, author, options)
      options.reverse_merge!({:cover_image => nil, :order => ManBook::ORDER_DEFAULT})

      # no further tests
    end

    def test_workproduct_cover(title, author, options)
      options.reverse_merge!({:cover_image => nil, :order => ManBook::ORDER_DEFAULT})

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

    def pages
      @fixtures.map do |fixture|
        ManBook::Parser.parse(File.join(FIXTURES_DIR, fixture))
      end
    end
  end
end
