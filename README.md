# MeetXT

MeetXT is a local-first Ruby CLI for developers and technical professionals who want to record meeting audio and turn recordings into readable, timestamped Markdown transcripts.

## Status

File-based transcription and local microphone recording are implemented for macOS.

## First useful version

The initial CLI accepts local MP3, M4A, and WAV recordings on macOS, transcribes audio through OpenAI using `OPENAI_API_KEY`, and writes UTF-8 Markdown beside the source file without overwriting existing output. It includes provider-supported `[HH:MM:SS]` timestamps and privacy-safe errors.

Audio is uploaded to the configured external transcription provider. Users are responsible for permission to record and upload meeting audio and for applicable confidentiality, privacy, and legal requirements.

## Setup

Install Ruby 3.3 and dependencies:

```bash
bundle install
```

Local recording also requires `ffmpeg` on `PATH` and macOS microphone permission for the terminal application. Verify the dependency with `ffmpeg -version` before recording.

## Usage

From the repository:

```bash
bundle exec exe/meetxt record meeting.wav
bundle exec exe/meetxt transcribe meeting.mp3
```

`record` captures the default macOS audio input through FFmpeg. Press Enter to stop; a successful recording prints the completed WAV path. Recording and transcription are deliberately separate, so pass the result to `meetxt transcribe meeting.wav` when ready.

After installing a built gem, omit `bundle exec exe/`. Transcripts are written beside the source as Markdown. Existing recordings and transcripts are never overwritten.

## Configuration

The transcription command requires:

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | yes | Credential for the OpenAI transcription provider |

Never commit API keys or meeting recordings.

MeetXT sends the selected audio file to OpenAI using `whisper-1`. You are responsible for permission to record and upload the audio and for applicable confidentiality, privacy, and legal requirements. MeetXT records the default audio input selected by FFmpeg; device selection is not configurable in this slice.

## Development

```bash
bundle exec rspec
bundle exec rubocop
bundle exec rake
gem build meetxt.gemspec
```

There is no static typecheck for the MVP. Automated tests use provider doubles and never call OpenAI.

For an optional paid smoke test, set `OPENAI_API_KEY` and run the normal command with a non-sensitive audio file. This is manual only and must never run in CI.

## Project context and workflow

Product context and requirements live in `.ai/project/` and `.ai/docs/project-requirements.md`.

The repository uses a private reusable workflow through the `.ai-template` submodule. If `.ai/README.md` is unavailable, run:

```bash
./scripts/setup-ai-workflow.sh
```

## Current limitations

- Recording targets the default macOS audio input and requires FFmpeg; custom device selection is deferred.
- Linux support, diarization, summaries, integrations, retries, cloud storage, and user accounts are deferred.

## License and maintainer

MeetXT is an open-source personal project maintained by Szymon Iwacz and licensed under the [MIT License](LICENSE).
