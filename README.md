# MeetXT

MeetXT is a local-first Ruby CLI for developers and technical professionals who want to turn meeting recordings into readable, timestamped Markdown transcripts.

## Status

The first usable CLI slice is implemented for file-based transcription on macOS.

## First useful version

The initial CLI accepts local MP3, M4A, and WAV recordings on macOS, transcribes audio through OpenAI using `OPENAI_API_KEY`, and writes UTF-8 Markdown beside the source file without overwriting existing output. It includes provider-supported `[HH:MM:SS]` timestamps and privacy-safe errors.

Audio is uploaded to the configured external transcription provider. Users are responsible for permission to record and upload meeting audio and for applicable confidentiality, privacy, and legal requirements.

## Setup

Install Ruby 3.3 and dependencies:

```bash
bundle install
```

## Usage

From the repository:

```bash
bundle exec exe/meetxt transcribe meeting.mp3
```

After installing a built gem, use `meetxt transcribe meeting.mp3`. The transcript is written beside the source as `meeting.md`. Existing output is never overwritten.

## Configuration

The transcription command requires:

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | yes | Credential for the OpenAI transcription provider |

Never commit API keys or meeting recordings.

MeetXT sends the selected audio file to OpenAI using `whisper-1`. You are responsible for permission to record and upload the audio and for applicable confidentiality, privacy, and legal requirements.

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

- The first version targets macOS and existing audio files only.
- Recording, Linux support, diarization, summaries, integrations, retries, cloud storage, and user accounts are deferred.

## License and maintainer

MeetXT is an open-source personal project maintained by Szymon Iwacz and licensed under the [MIT License](LICENSE).
