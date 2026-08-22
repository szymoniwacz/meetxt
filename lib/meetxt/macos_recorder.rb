# frozen_string_literal: true

require "open3"
require "pathname"
require "rbconfig"
require "securerandom"

module Meetxt
  class MacOSRecorder
    COMMAND = %w[ffmpeg -hide_banner -loglevel error -n -f avfoundation -i :0 -c:a pcm_s16le].freeze

    def initialize(host_os: RbConfig::CONFIG["host_os"], command_runner: Open3)
      @host_os = host_os
      @command_runner = command_runner
    end

    def record(output, input:, err:)
      path = Pathname(output).expand_path
      validate(path)
      temporary = temporary_path(path)

      err.puts("Recording to #{path}. Press Enter to stop.")
      status = run_ffmpeg(temporary, input)
      validate_result(temporary, status)
      publish(temporary, path)
      path.to_s
    rescue SystemCallError => e
      raise RecordingError, "Could not record audio: #{e.message}"
    ensure
      cleanup(temporary)
    end

    private

    def validate(path)
      raise RecordingError, "Recording is supported on macOS only." unless @host_os.match?(/darwin/)
      raise InputError, "Recording output must use the .wav extension: #{path}" unless path.extname.downcase == ".wav"
      raise OutputExistsError, path if path.exist?
      raise FileWriteError, path unless path.dirname.directory? && path.dirname.writable?
    end

    def run_ffmpeg(path, input)
      @command_runner.popen3(*COMMAND, path.to_s) do |stdin, _stdout, stderr, wait_thread|
        stop_thread = Thread.new { input.gets }
        sleep(0.05) while wait_thread.alive? && stop_thread.alive?
        stdin.puts("q") if wait_thread.alive?
        stdin.close
        stop_thread.kill if stop_thread.alive?
        error = stderr.read
        status = wait_thread.value
        raise RecordingError, recording_failure(error) unless status.success?

        status
      end
    rescue Errno::ENOENT
      raise RecordingError, "Could not start recording: ffmpeg is not installed or is not available on PATH."
    end

    def validate_result(path, status)
      return if status.success? && path.file? && !path.zero?

      raise RecordingError, "Recording stopped without producing audio. Check the local audio device and permissions."
    end

    def temporary_path(path)
      path.dirname.join(".#{path.basename}.#{Process.pid}.#{SecureRandom.hex(6)}.wav")
    end

    def publish(temporary, path)
      File.link(temporary, path)
    rescue Errno::EEXIST
      raise OutputExistsError, path
    rescue SystemCallError
      raise FileWriteError, path
    end

    def recording_failure(error)
      detail = error.to_s.lines.last&.strip
      base = "Recording failed. Check ffmpeg, the local audio device, and microphone permissions."
      detail.nil? || detail.empty? ? base : "#{base} (#{detail})"
    end

    def cleanup(temporary)
      temporary&.delete if temporary&.file?
    rescue SystemCallError
      nil
    end
  end
end
