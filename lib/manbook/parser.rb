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
        title = Nokogiri::HTML(File.read(html_file)).xpath("//b[text() = 'NAME']/../following-sibling::p[1]/descendant-or-self::text()").to_s
        {:file_name => File.basename(html_file), :title => title}
      end
    end
  end
end
