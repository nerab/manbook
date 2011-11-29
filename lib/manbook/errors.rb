module ManBook
  class ConfigurationError < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class CommandFailedError < ConfigurationError
    attr_reader :cmd, :msg

    def initialize(cmd, msg)
      super("Executing #{cmd} failed: #{msg}")
      @cmd, @msg = cmd, msg
    end
  end

  class ManPageNotFoundError < ConfigurationError
    def initialize(man_page)
      super(man_page)
    end
  end
end
