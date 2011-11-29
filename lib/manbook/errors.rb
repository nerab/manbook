module ManBook
  class ConfigurationError < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class CommandFailedError < ConfigurationError
    def initialize(cmd, msg)
      super("Executing #{cmd} failed: #{msg}")
    end
  end

  class ManPageNotFoundError < ConfigurationError
    def initialize(ambiguousSource)
      super("No man page found for #{ambiguousSource}.")
    end
  end
end
