module ManBook
  class Parser
    class << self
      def parse(html_file)
        #
        # The way we extract the title is highly dependent of the concrete HTML. Yet, I found no other way
        # to extract the title of a man page ín a reliable way.
        #
        title = Nokogiri::HTML(File.read(html_file)).xpath("//b[text() = 'NAME']/../following-sibling::p[1]/descendant-or-self::text()").to_s
        {:file_name => File.basename(html_file), :title => title}
      end
    end
  end
end
