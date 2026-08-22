# frozen_string_literal: true

module Meetxt
  class Error < StandardError
    attr_reader :exit_code

    def initialize(message, exit_code: 70)
      super(message)
      @exit_code = exit_code
    end
  end

  class UsageError < Error
    def initialize(message)
      super(message, exit_code: 64)
    end
  end

  class InputError < Error
    def initialize(message)
      super(message, exit_code: 66)
    end
  end

  class OutputExistsError < Error
    def initialize(path)
      super("Output file already exists: #{path}", exit_code: 73)
    end
  end

  class FileWriteError < Error
    def initialize(path)
      super("Could not write transcript: #{path}", exit_code: 73)
    end
  end

  class RecordingError < Error
    def initialize(message)
      super(message, exit_code: 69)
    end
  end

  class ConfigurationError < Error
    def initialize(message)
      super(message, exit_code: 78)
    end
  end

  class ProviderError < Error
    def initialize(message)
      super(message, exit_code: 69)
    end
  end
end
