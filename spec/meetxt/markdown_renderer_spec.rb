# frozen_string_literal: true

RSpec.describe Meetxt::MarkdownRenderer do
  subject(:renderer) { described_class.new }

  it "renders UTF-8 metadata and floored segment timestamps" do
    transcript = Meetxt::Transcript.new(
      provider: "OpenAI Whisper",
      model: "whisper-1",
      duration: 67.9,
      segments: [
        Meetxt::Segment.new(start: 12.9, text: " Zażółć gęślą jaźń."),
        Meetxt::Segment.new(start: 3727.2, text: "Next segment.")
      ]
    )
    time = Time.new(2026, 8, 20, 9, 22, 0, "+02:00")

    markdown = renderer.render(source: Pathname("/tmp/meeting.mp3"), transcript:, transcribed_at: time)

    expect(markdown).to eq(<<~MARKDOWN)
      # meeting

      - Source: meeting.mp3
      - Transcribed: 2026-08-20T09:22:00+02:00
      - Provider: OpenAI Whisper
      - Model: whisper-1
      - Duration: 00:01:07

      ## Transcript

      [00:00:12]  Zażółć gęślą jaźń.

      [01:02:07] Next segment.
    MARKDOWN
    expect(markdown.encoding).to eq(Encoding::UTF_8)
  end

  it "omits duration when the provider does not return it" do
    transcript = Meetxt::Transcript.new(
      provider: "OpenAI Whisper",
      model: "whisper-1",
      duration: nil,
      segments: [Meetxt::Segment.new(start: 0, text: "Hello")]
    )

    markdown = renderer.render(source: Pathname("meeting.wav"), transcript:, transcribed_at: Time.now)

    expect(markdown).not_to include("Duration:")
  end
end
