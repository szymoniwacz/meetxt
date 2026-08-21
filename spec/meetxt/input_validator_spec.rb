# frozen_string_literal: true

RSpec.describe Meetxt::InputValidator do
  subject(:validator) { described_class.new }

  around do |example|
    Dir.mktmpdir do |directory|
      @directory = Pathname(directory)
      example.run
    end
  end

  it "accepts a real WAV fixture" do
    path = Pathname(__dir__).join("../fixtures/audio/reported_speech.wav").expand_path

    expect(validator.validate!(path)).to eq(path)
  end

  it "accepts supported audio formats case-insensitively" do
    path = @directory.join("meeting.MP3")
    path.binwrite("audio")

    expect(validator.validate!(path)).to eq(path)
  end

  it "rejects a missing file" do
    path = @directory.join("missing.mp3")

    expect { validator.validate!(path) }.to raise_error(Meetxt::InputError, /does not exist/)
  end

  it "rejects a directory" do
    path = @directory.join("meeting.mp3")
    path.mkdir

    expect { validator.validate!(path) }.to raise_error(Meetxt::InputError, /not a file/)
  end

  it "rejects an unsupported extension" do
    path = @directory.join("meeting.flac")
    path.binwrite("audio")

    expect { validator.validate!(path) }.to raise_error(Meetxt::InputError, /Unsupported audio format/)
  end

  it "rejects an unreadable file" do
    path = instance_double(Pathname, exist?: true, file?: true, extname: ".wav", readable?: false)

    expect { validator.validate!(path) }.to raise_error(Meetxt::InputError, /not readable/)
  end

  it "rejects an empty file" do
    path = @directory.join("meeting.wav")
    path.binwrite("")

    expect { validator.validate!(path) }.to raise_error(Meetxt::InputError, /empty/)
  end
end
