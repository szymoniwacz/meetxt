# frozen_string_literal: true

require "uri"

RSpec.describe Meetxt::Providers::OpenAIAdapter do
  let(:transcriptions) { instance_double("OpenAI transcriptions") }
  let(:audio) { instance_double("OpenAI audio", transcriptions:) }
  let(:client) { instance_double(OpenAI::Client, audio:) }
  let(:adapter) { described_class.new(api_key: "unused-test-key", client:) }
  let(:path) { Pathname("meeting.mp3") }

  def sdk_response(payload)
    OpenAI::Internal::Type::Converter.coerce(OpenAI::Audio::TranscriptionCreateResponse, payload)
  end

  it "requests verbose segment timestamps exactly once and maps the response" do
    response = sdk_response(
      text: "Hello",
      language: "english",
      duration: 42.5,
      segments: [{ start: 12.8, end: 14.2, text: "Hello" }]
    )
    expect(response).to be_a(OpenAI::Audio::Transcription)
    expect(response).not_to respond_to(:segments)
    expect(transcriptions).to receive(:create).once.with(
      file: path,
      model: "whisper-1",
      response_format: :verbose_json,
      timestamp_granularities: [:segment]
    ).and_return(response)

    transcript = adapter.transcribe(path)

    expect(transcript.provider).to eq("OpenAI Whisper")
    expect(transcript.model).to eq("whisper-1")
    expect(transcript.duration).to eq(42.5)
    expect(transcript.segments.first).to have_attributes(start: 12.8, text: "Hello")
  end

  it "serializes the verbose response format and bracketed timestamp array for multipart upload" do
    params, = OpenAI::Audio::TranscriptionCreateParams.dump_request(
      file: StringIO.new("audio"),
      model: "whisper-1",
      response_format: :verbose_json,
      timestamp_granularities: [:segment]
    )
    _, body = OpenAI::Internal::Util.encode_content({ "content-type" => "multipart/form-data" }, params)
    multipart = body.to_a.join

    expect(multipart).to match(/name="response_format".*?\r\n\r\nverbose_json\r\n/m)
    expect(multipart).to match(/name="timestamp_granularities\[\]".*?\r\n\r\nsegment\r\n/m)
  end

  it "disables SDK retries and logging on the default client" do
    expect(OpenAI::Client).to receive(:new).with(
      api_key: "test-key",
      log_level: :off,
      max_retries: 0
    ).and_return(client)

    described_class.new(api_key: "test-key")
  end

  it "rejects a response without timestamped segments" do
    response = sdk_response(text: "Hello")
    allow(transcriptions).to receive(:create).and_return(response)

    expect { adapter.transcribe(path) }
      .to raise_error(Meetxt::ProviderError, /did not include timestamped transcript segments/)
  end

  {
    OpenAI::Errors::AuthenticationError => [Meetxt::ConfigurationError, "OpenAI authentication failed"],
    OpenAI::Errors::PermissionDeniedError => [Meetxt::ConfigurationError, "OpenAI authentication failed"],
    OpenAI::Errors::RateLimitError => [Meetxt::ProviderError, "OpenAI rate limit reached"],
    OpenAI::Errors::InternalServerError => [Meetxt::ProviderError, "OpenAI is temporarily unavailable"],
    OpenAI::Errors::APIConnectionError => [Meetxt::ProviderError, "Could not reach OpenAI"],
    OpenAI::Errors::APITimeoutError => [Meetxt::ProviderError, "Could not reach OpenAI"],
    OpenAI::Errors::APIStatusError => [Meetxt::ProviderError, "OpenAI rejected the transcription request"],
    OpenAI::Errors::ConversionError => [Meetxt::ProviderError, "response that could not be processed"]
  }.each do |sdk_error, (meetxt_error, message)|
    it "sanitizes #{sdk_error.name}" do
      provider_error = sdk_error.allocate
      allow(provider_error).to receive(:message).and_return("raw response with test-secret")
      allow(transcriptions).to receive(:create).and_raise(provider_error)

      expect { adapter.transcribe(path) }.to raise_error(meetxt_error, /#{Regexp.escape(message)}/) do |error|
        expect(error.message).not_to include("test-secret")
      end
    end
  end
end
