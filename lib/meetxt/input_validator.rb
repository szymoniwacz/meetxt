# frozen_string_literal: true

module Meetxt
  class InputValidator
    SUPPORTED_EXTENSIONS = %w[.mp3 .m4a .wav].freeze

    def validate!(path)
      raise InputError, "Input file does not exist: #{path}" unless path.exist?
      raise InputError, "Input path is not a file: #{path}" unless path.file?
      raise InputError, "Unsupported audio format: #{path.extname}" unless supported?(path)
      raise InputError, "Input file is not readable: #{path}" unless path.readable?
      raise InputError, "Input file is empty: #{path}" if path.zero?

      path
    end

    private

    def supported?(path)
      SUPPORTED_EXTENSIONS.include?(path.extname.downcase)
    end
  end
end
