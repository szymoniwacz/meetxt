# frozen_string_literal: true

require "openai"
require "pathname"

module Meetxt
  module Providers
    class OpenAIAdapter
      MODEL = "whisper-1"
      PROVIDER = "OpenAI Whisper"

      def initialize(api_key:, client: nil)
        @client = client || OpenAI::Client.new(api_key: api_key, log_level: :off, max_retries: 0)
      end

      def transcribe(path)
        response = @client.audio.transcriptions.create(
          file: Pathname(path),
          model: MODEL,
          response_format: :verbose_json,
          timestamp_granularities: [:segment]
        )
        build_transcript(response)
      rescue OpenAI::Errors::AuthenticationError, OpenAI::Errors::PermissionDeniedError
        raise ConfigurationError, "OpenAI authentication failed. Check OPENAI_API_KEY."
      rescue OpenAI::Errors::RateLimitError
        raise ProviderError, "OpenAI rate limit reached. Try again later."
      rescue OpenAI::Errors::APIConnectionError, OpenAI::Errors::APITimeoutError
        raise ProviderError, "Could not reach OpenAI. Check the network connection and try again."
      rescue OpenAI::Errors::InternalServerError
        raise ProviderError, "OpenAI is temporarily unavailable. Try again later."
      rescue OpenAI::Errors::APIStatusError
        raise ProviderError, "OpenAI rejected the transcription request. Check the audio file and provider limits."
      rescue OpenAI::Errors::Error
        raise ProviderError, "OpenAI returned a response that could not be processed."
      end

      private

      def build_transcript(response)
        segments = Array(response.segments).map { |segment| Segment.new(start: segment.start, text: segment.text) }
        raise ProviderError, "Provider response did not include timestamped transcript segments." if segments.empty?

        Transcript.new(provider: PROVIDER, model: MODEL, segments: segments, duration: response.duration)
      end
    end
  end
end
