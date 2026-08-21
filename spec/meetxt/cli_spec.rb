# frozen_string_literal: true

RSpec.describe Meetxt::CLI do
  around do |example|
    Dir.mktmpdir do |directory|
      @directory = Pathname(directory)
      example.run
    end
  end

  let(:out) { StringIO.new }
  let(:err) { StringIO.new }
  let(:env) { { "OPENAI_API_KEY" => "test-key" } }
  let(:provider) { instance_double("provider") }
  let(:provider_factory) do
    lambda do |key|
      expect(key).to eq("test-key")
      provider
    end
  end
  let(:transcript) do
    Meetxt::Transcript.new(
      provider: "OpenAI Whisper",
      model: "whisper-1",
      duration: nil,
      segments: [Meetxt::Segment.new(start: 2, text: "Hello")]
    )
  end

  it "completes the CLI transcription flow quietly" do
    source = @directory.join("meeting.mp3")
    source.binwrite("audio")
    allow(provider).to receive(:transcribe).and_return(transcript)

    status = described_class.start(["transcribe", source.to_s], out:, err:, env:, provider_factory:)

    expect(status).to eq(0)
    expect(out.string).to eq("#{@directory.join('meeting.md')}\n")
    expect(err.string).to be_empty
    expect(@directory.join("meeting.md").read).to include("[00:00:02] Hello")
  end

  it "prints help and version" do
    expect(described_class.start(["--help"], out:, err:, env:)).to eq(0)
    expect(out.string).to eq("Usage: meetxt transcribe <audio-file>\n")

    out.truncate(0)
    out.rewind
    expect(described_class.start(["--version"], out:, err:, env:)).to eq(0)
    expect(out.string).to eq("meetxt #{Meetxt::VERSION}\n")
  end

  it "shows usage for a missing or invalid command" do
    expect(described_class.start([], out:, err:, env:)).to eq(64)
    expect(err.string).to eq("Usage: meetxt transcribe <audio-file>\n")
  end

  it "reports missing configuration without exposing secrets" do
    status = described_class.start(["transcribe", "meeting.mp3"], out:, err:, env: {}, provider_factory:)

    expect(status).to eq(78)
    expect(err.string).to eq("OPENAI_API_KEY is not set.\n")
  end

  it "reports provider failures on stderr" do
    source = @directory.join("meeting.wav")
    source.binwrite("audio")
    allow(provider).to receive(:transcribe).and_raise(Meetxt::ProviderError, "OpenAI is unavailable.")

    status = described_class.start(["transcribe", source.to_s], out:, err:, env:, provider_factory:)

    expect(status).to eq(69)
    expect(out.string).to be_empty
    expect(err.string).to eq("OpenAI is unavailable.\n")
  end

  it "reports local input failures without calling the provider" do
    source = @directory.join("meeting.flac")
    source.binwrite("audio")
    allow(provider).to receive(:transcribe)

    status = described_class.start(["transcribe", source.to_s], out:, err:, env:, provider_factory:)

    expect(status).to eq(66)
    expect(out.string).to be_empty
    expect(err.string).to include("Unsupported audio format")
    expect(provider).not_to have_received(:transcribe)
  end

  it "reports file-write failures without partial successful output" do
    source = @directory.join("meeting.mp3")
    source.binwrite("audio")
    output = @directory.join("meeting.md")
    writer = instance_double(Meetxt::AtomicWriter)
    allow(provider).to receive(:transcribe).and_return(transcript)
    allow(Meetxt::AtomicWriter).to receive(:new).and_return(writer)
    allow(writer).to receive(:write).and_raise(Meetxt::FileWriteError, output)

    status = described_class.start(["transcribe", source.to_s], out:, err:, env:, provider_factory:)

    expect(status).to eq(73)
    expect(out.string).to be_empty
    expect(err.string).to eq("Could not write transcript: #{output}\n")
    expect(output).not_to exist
  end

  it "protects existing output before provider use" do
    source = @directory.join("meeting.wav")
    source.binwrite("audio")
    output = @directory.join("meeting.md")
    output.write("existing")

    status = described_class.start(["transcribe", source.to_s], out:, err:, env:, provider_factory:)

    expect(status).to eq(73)
    expect(err.string).to include("already exists")
    expect(output.read).to eq("existing")
  end
end
