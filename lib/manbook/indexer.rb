
module ManBook
  class Indexer
    class << self
      def index(src_dir)
        result = Array.new
        10.times{|i|
          result << {:file_name => "ls_#{i}.html", :title => "ls - list structure #{i}"}
        }
        result
      end
    end
  end
end
