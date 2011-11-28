module ManBook
  class ConfigurationError < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class AmbiguousManPageError < ConfigurationError
    def initialize(ambiguousSource)
      super("There is more than one man page for #{ambiguousSource}. Please specify the man section.")
    end
  end

  class ManPageNotFoundError < ConfigurationError
    def initialize(ambiguousSource)
      super("No man page found for #{ambiguousSource}.")
    end
  end
end
