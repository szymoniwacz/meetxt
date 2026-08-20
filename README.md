# MeetXT

MeetXT is a planned local-first Ruby CLI for developers and technical professionals who want to turn meeting recordings into readable, timestamped Markdown transcripts.

## Status

Project readiness is complete; product implementation has not started. The first product task may create the real Ruby CLI scaffold and implement `meetxt transcribe <audio-file>`.

## First useful version

The initial CLI will accept local MP3, M4A, and WAV recordings on macOS, transcribe audio through OpenAI using `OPENAI_API_KEY`, and write UTF-8 Markdown beside the source file without overwriting existing output. It will include provider-supported `[HH:MM:SS]` timestamps and privacy-safe errors.

Audio will be uploaded to the configured external transcription provider. Users are responsible for permission to record and upload meeting audio and for applicable confidentiality, privacy, and legal requirements.

## Planned interface

```bash
meetxt transcribe meeting.mp3
```

The command does not exist yet. Setup, test, lint, build, and run commands will be recorded when the first product task creates the actual Ruby CLI scaffold.

## Configuration

The implemented transcription command will require:

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | yes | Credential for the OpenAI transcription provider |

Never commit API keys or meeting recordings.

## Project context and workflow

Product context and requirements live in `.ai/project/` and `.ai/docs/project-requirements.md`.

The repository uses a private reusable workflow through the `.ai-template` submodule. If `.ai/README.md` is unavailable, run:

```bash
./scripts/setup-ai-workflow.sh
```

## Current limitations

- No product behavior or Ruby application scaffold is implemented yet.
- The first version targets macOS and existing audio files only.
- Recording, Linux support, diarization, summaries, integrations, retries, cloud storage, and user accounts are deferred.

## License and maintainer

MeetXT is an open-source personal project maintained by Szymon Iwacz and licensed under the [MIT License](LICENSE).
