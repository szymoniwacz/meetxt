# frozen_string_literal: true

module Meetxt
  class CLI
    USAGE = "Usage: meetxt transcribe <audio-file>"

    def self.start(argv, out: $stdout, err: $stderr, env: ENV, provider_factory: nil)
      new(out:, err:, env:, provider_factory:).run(argv)
    end

    def initialize(out:, err:, env:, provider_factory: nil)
      @out = out
      @err = err
      @env = env
      @provider_factory = provider_factory || ->(api_key) { Providers::OpenAIAdapter.new(api_key:) }
    end

    def run(argv)
      return print_help if argv == ["--help"]
      return print_version if argv == ["--version"]
      raise UsageError, USAGE unless argv.length == 2 && argv.first == "transcribe"

      path = transcribe(argv.last)
      @out.puts(path)
      0
    rescue Error => e
      @err.puts(e.message)
      @err.puts(USAGE) if e.is_a?(UsageError) && e.message != USAGE
      e.exit_code
    end

    private

    def transcribe(input)
      api_key = @env["OPENAI_API_KEY"]
      raise ConfigurationError, "OPENAI_API_KEY is not set." if api_key.nil? || api_key.empty?

      provider = @provider_factory.call(api_key)
      TranscriptionService.new(provider:).call(input)
    end

    def print_help
      @out.puts(USAGE)
      0
    end

    def print_version
      @out.puts("meetxt #{VERSION}")
      0
    end
  end
end
