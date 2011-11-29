module ManBook
  class Parser
    class << self
      def parse(html_file)
        #
        # The way we extract the title is highly dependent of the concrete HTML. Yet, I found no other way
        # to extract the title of a man page ín a reliable way.
        #
        # TODO For git, less, gunzip:
        # <h2>NAME</h2>
        # <p style="margin-left:11%; margin-top: 1em">git &minus; the stupid content tracker</p>
        #
        doc = Nokogiri::HTML(File.read(html_file))
        
        title = doc.xpath("//b[text() = 'NAME']/../following-sibling::p[1]/descendant-or-self::text()").to_s 
        
        if title.empty?
          title = doc.xpath("//h2[text() = 'NAME']/following-sibling::p[1]/descendant-or-self::text()").to_s
        end
        
        {:file_name => File.basename(html_file), :title => title}
      end
    end
  end
end
