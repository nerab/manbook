module ManBook
  class Parser
    class << self
      def parse(html_file)
        #
        # The way we extract the title is highly dependent of the concrete HTML. Yet, I found no other way
        # to extract the title of a man page ín a reliable way.
        #
        doc = Nokogiri::HTML(File.read(html_file))

        title = doc.xpath("//b[text() = 'NAME']/../following-sibling::p[1]/descendant-or-self::text()").to_s

        if title.blank?
          title = doc.xpath("//h2[text() = 'NAME']/following-sibling::p[1]/descendant-or-self::text()").to_s
        end

        # fall back to document title
        if title.blank?
          title = doc.xpath("//html/head/title/text()").to_s
        end

        author = doc.xpath("//b[text() = 'AUTHORS']/../following-sibling::p[1]/descendant-or-self::text()").to_s

        if author.empty?
          author = doc.xpath("//h2[text() = 'AUTHORS']/following-sibling::p[1]/descendant-or-self::text()").to_s
        end

        {:file_name => File.basename(html_file), :title => title.split("\n").join(' '), :author => author.split("\n").join(' ')}
      end
    end
  end
end
