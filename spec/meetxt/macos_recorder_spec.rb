# frozen_string_literal: true

RSpec.describe Meetxt::MacOSRecorder do
  let(:fake_status_class) { Struct.new(:success?) }
  let(:wait_thread_class) do
    status_class = fake_status_class
    Class.new do
      attr_reader :pid

      define_method(:initialize) do |success:|
        @pid = 12_345
        @status = status_class.new(success)
        @alive = success
      end

      def alive? = @alive
      def value = @status
      def stop = @alive = false
    end
  end
  let(:runner_class) do
    thread_class = wait_thread_class
    Class.new do
      attr_reader :command, :stdin

      define_method(:initialize) do |success: true, error: "", &on_run|
        @success = success
        @error = error
        @on_run = on_run
      end

      define_method(:popen3) do |*command, &block|
        @command = command
        @on_run&.call(Pathname(command.last))
        wait_thread = thread_class.new(success: @success)
        @stdin = StringIO.new
        @stdin.define_singleton_method(:puts) do |value|
          super(value).tap { wait_thread.stop }
        end
        block.call(@stdin, StringIO.new, StringIO.new(@error), wait_thread)
      end
    end
  end

  around do |example|
    Dir.mktmpdir do |directory|
      @directory = Pathname(directory)
      example.run
    end
  end

  let(:output) { @directory.join("meeting.wav") }
  let(:input) { StringIO.new("\n") }
  let(:err) { StringIO.new }

  it "records a non-empty WAV with the macOS AVFoundation input" do
    runner = runner_class.new { |path| path.binwrite("RIFF audio") }
    recorder = described_class.new(host_os: "darwin23", command_runner: runner)

    result = recorder.record(output, input:, err:)

    expect(result).to eq(output.to_s)
    expect(runner.command.take(described_class::COMMAND.length)).to eq(described_class::COMMAND)
    expect(runner.command.last).to end_with(".wav")
    expect(runner.stdin.string).to eq("q\n")
    expect(output.binread).to eq("RIFF audio")
    expect(err.string).to include("Press Enter to stop")
  end

  it "rejects unsupported systems before starting ffmpeg" do
    recorder = described_class.new(host_os: "linux", command_runner: runner_class.new)

    expect { recorder.record(output, input:, err:) }
      .to raise_error(Meetxt::RecordingError, "Recording is supported on macOS only.")
  end

  it "refuses an existing output" do
    output.binwrite("existing")
    recorder = described_class.new(host_os: "darwin", command_runner: runner_class.new)

    expect { recorder.record(output, input:, err:) }.to raise_error(Meetxt::OutputExistsError)
    expect(output.binread).to eq("existing")
  end

  it "rejects output formats that the transcription flow cannot consume" do
    recorder = described_class.new(host_os: "darwin", command_runner: runner_class.new)

    expect { recorder.record(@directory.join("meeting.aiff"), input:, err:) }
      .to raise_error(Meetxt::InputError, /must use the .wav extension/)
  end

  it "removes output when ffmpeg fails" do
    runner = runner_class.new(success: false, error: "audio device unavailable\n") do |path|
      path.binwrite("partial")
    end
    recorder = described_class.new(host_os: "darwin", command_runner: runner)

    expect { recorder.record(output, input:, err:) }.to raise_error(Meetxt::RecordingError, /Recording failed/)
    expect(output).not_to exist
  end

  it "does not replace an output that appears while recording" do
    runner = runner_class.new do |temporary|
      temporary.binwrite("recorded")
      output.binwrite("competing output")
    end
    recorder = described_class.new(host_os: "darwin", command_runner: runner)

    expect { recorder.record(output, input:, err:) }.to raise_error(Meetxt::OutputExistsError)
    expect(output.binread).to eq("competing output")
    expect(@directory.children.grep(/\.meeting\.wav\./)).to be_empty
  end

  it "removes an empty recording instead of reporting success" do
    runner = runner_class.new { |path| path.binwrite("") }
    recorder = described_class.new(host_os: "darwin", command_runner: runner)

    expect { recorder.record(output, input:, err:) }
      .to raise_error(Meetxt::RecordingError, /without producing audio/)
    expect(output).not_to exist
  end

  it "reports missing ffmpeg clearly" do
    runner = Class.new do
      def self.popen3(*)
        raise Errno::ENOENT
      end
    end
    recorder = described_class.new(host_os: "darwin", command_runner: runner)

    expect { recorder.record(output, input:, err:) }
      .to raise_error(Meetxt::RecordingError, /ffmpeg is not installed/)
  end
end
