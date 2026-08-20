# Product Context

## Product

- Name: MeetXT
- Purpose: Convert existing local meeting recordings into timestamped Markdown through an external transcription API.
- Users: Developers and technical professionals who want a small local-first CLI workflow.
- Primary outcome: `meetxt transcribe meeting.mp3` creates `meeting.md` or reports a safe, actionable error.

## Repository

- Main stack: Ruby 3.3 gem with a `meetxt` executable.
- Tooling: Bundler, RSpec, RuboCop, and GitHub Actions.
- Commands: Establish real build, run, test, lint, and packaging commands during template customization.
- Boundary: CLI → transcription service → OpenAI adapter → Markdown renderer → atomic file writer.

## Constraints

- MVP accepts local MP3, M4A, and WAV files on macOS.
- `OPENAI_API_KEY` is the only required configuration.
- Audio goes to OpenAI; MeetXT retains no uploaded copy or intermediate data.
- Existing outputs are never overwritten.
- Keys, transcript content, and raw API bodies are never logged or exposed by default.
- Keep runtime dependencies minimal and provider code isolated.
