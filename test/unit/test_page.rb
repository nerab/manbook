require 'helper'

module ManBookTest
  class TestPage < ManBookTest::TestCase
    def test_about
      file_name = 'about.html'
      page = ManBook::Parser.parse(fixture(file_name))
      refute_nil(page)
      assert_equal('About this book', page.title)
      assert_equal('', page.author)
      assert_equal(file_name, page.file_name)
    end

    def test_cat
      file_name = 'cat.html'
      page = ManBook::Parser.parse(fixture(file_name))
      refute_nil(page)
      assert_equal('cat — concatenate and print files', page.title)
      assert_equal('', page.author)
      assert_equal(file_name, page.file_name)
    end

    def test_git
      file_name = 'git.html'
      page = ManBook::Parser.parse(fixture(file_name))
      refute_nil(page)
      assert_equal('git − the stupid content tracker', page.title)
      assert_match(/Linus Torvalds/, page.author)
      assert_equal(file_name, page.file_name)
    end

    private

    def fixture(basename)
      File.join(FIXTURES_DIR, basename)
    end
  end
end
