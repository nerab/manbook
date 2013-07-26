require 'helper'

module ManBookTest
  class TestPage < ManBookTest::TestCase
    def test_about
      file_name = 'about.html'
      page = ManBook::Parser.parse(fixture(file_name))
      refute_nil(page)
      assert_equal('About this book', page[:title])
      assert_equal('', page[:author])
      assert_equal(file_name, page[:file_name])
    end

    private

    def fixture(basename)
      File.join(FIXTURES_DIR, basename)
    end
  end
end
