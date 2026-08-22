# frozen_string_literal: true

module Meetxt
  class CLI
    USAGE = <<~TEXT
      Usage:
        meetxt transcribe <audio-file>
        meetxt record <output.wav>
    TEXT

    def self.start(argv, io: {}, env: ENV, factories: {})
      new(
        out: io.fetch(:out, $stdout),
        err: io.fetch(:err, $stderr),
        input: io.fetch(:input, $stdin),
        env:,
        factories:
      ).run(argv)
    end

    def initialize(out:, err:, input:, env:, factories:)
      @out = out
      @err = err
      @input = input
      @env = env
      @provider_factory = factories.fetch(:provider, ->(api_key) { Providers::OpenAIAdapter.new(api_key:) })
      @recorder_factory = factories.fetch(:recorder, -> { MacOSRecorder.new })
    end

    def run(argv)
      return print_help if argv == ["--help"]
      return print_version if argv == ["--version"]

      path = dispatch(argv)
      @out.puts(path)
      0
    rescue Error => e
      @err.puts(e.message)
      @err.puts(USAGE) if e.is_a?(UsageError) && e.message != USAGE
      e.exit_code
    end

    private

    def dispatch(argv)
      raise UsageError, USAGE unless argv.length == 2

      return transcribe(argv.last) if argv.first == "transcribe"
      return record(argv.last) if argv.first == "record"

      raise UsageError, USAGE
    end

    def transcribe(input)
      api_key = @env["OPENAI_API_KEY"]
      raise ConfigurationError, "OPENAI_API_KEY is not set." if api_key.nil? || api_key.empty?

      provider = @provider_factory.call(api_key)
      TranscriptionService.new(provider:).call(input)
    end

    def record(output)
      @recorder_factory.call.record(output, input: @input, err: @err)
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
