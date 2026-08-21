# frozen_string_literal: true

RSpec.describe Meetxt::TranscriptionService do
  around do |example|
    Dir.mktmpdir do |directory|
      @directory = Pathname(directory)
      example.run
    end
  end

  let(:source) { @directory.join("meeting.m4a") }
  let(:provider) { instance_double("provider") }
  let(:transcript) do
    Meetxt::Transcript.new(
      provider: "OpenAI Whisper",
      model: "whisper-1",
      duration: 10,
      segments: [Meetxt::Segment.new(start: 1, text: "Hello")]
    )
  end

  before { source.binwrite("audio") }

  it "transcribes once and writes beside the source" do
    allow(provider).to receive(:transcribe).with(source).once.and_return(transcript)
    service = described_class.new(provider:, clock: -> { Time.new(2026, 8, 20, 9, 22, 0, "+02:00") })

    output = service.call(source.to_s)

    expect(output).to eq(@directory.join("meeting.md"))
    expect(output.read).to include("[00:00:01] Hello")
  end

  it "checks output collision before calling the provider" do
    @directory.join("meeting.md").write("existing")
    allow(provider).to receive(:transcribe)

    expect { described_class.new(provider:).call(source.to_s) }.to raise_error(Meetxt::OutputExistsError)
    expect(provider).not_to have_received(:transcribe)
  end

  it "validates the source before calling the provider" do
    source.delete
    allow(provider).to receive(:transcribe)

    expect { described_class.new(provider:).call(source.to_s) }.to raise_error(Meetxt::InputError)
    expect(provider).not_to have_received(:transcribe)
  end
end
