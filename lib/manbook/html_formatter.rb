module ManBook
  class HtmlFormatter < Formatter
    def convert(file_name)
      # pipe through gunzip if gzipped
      if man_page_file =~ /\.gz$/
        cmd = "gunzip -c #{man_page_file} | groff -mandoc -T html > #{file_name}"
      else
        cmd = "groff -mandoc #{man_page_file} -T html > #{file_name}"
      end

      ManBook.logger.debug("Executing #{cmd}")
      execute(cmd)
      ManBook.logger.info "Written man page for '#{man_page}' to '#{file_name}'"
    end
  end
end

