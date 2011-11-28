require 'logger'

module ManBook
  class LogFormatter < Logger::Formatter
    def call(severity, time, program_name, message)
      "#{severity}: #{message}\n"
    end
  end
end
