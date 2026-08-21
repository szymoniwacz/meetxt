# frozen_string_literal: true

require "time"

module Meetxt
  class MarkdownRenderer
    def render(source:, transcript:, transcribed_at:)
      metadata = [
        "# #{source.basename(source.extname)}",
        "",
        "- Source: #{source.basename}",
        "- Transcribed: #{transcribed_at.iso8601}",
        "- Provider: #{transcript.provider}",
        "- Model: #{transcript.model}"
      ]
      metadata << "- Duration: #{format_duration(transcript.duration)}" if transcript.duration

      body = transcript.segments.map do |segment|
        "[#{format_timestamp(segment.start)}] #{segment.text}"
      end

      [*metadata, "", "## Transcript", "", body.join("\n\n"), ""].join("\n").encode(Encoding::UTF_8)
    end

    private

    def format_timestamp(seconds)
      total = seconds.to_f.floor
      format(
        "%<hours>02d:%<minutes>02d:%<seconds>02d",
        hours: total / 3600,
        minutes: (total % 3600) / 60,
        seconds: total % 60
      )
    end

    def format_duration(seconds)
      format_timestamp(seconds)
    end
  end
end
