module ManBook
  class Formatter
    def initialize(man_page)
      @man_page = man_page
      begin
        @man_page_file = execute("man -w #{man_page}").chomp!
      rescue ManBook::CommandFailedError => e
        raise ManBook::ManPageNotFoundError.new(e.msg)
      end

      ManBook.logger.debug("Located man page at #{@man_page_file}")
    end

protected
    attr_reader :man_page, :man_page_file

    def execute(cmd)
      out, err = nil
      status = Open4::popen4(cmd){|pid, stdin, stdout, stderr|
        out = stdout.read
        err = stderr.read
      }
      raise ManBook::CommandFailedError.new(cmd, err.chomp) if 0 != status # $?
      out
    end
  end
end
