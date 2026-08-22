# Product Context

## Product

- Name: MeetXT
- Purpose: Record meeting audio locally and convert local meeting recordings into timestamped Markdown through an external transcription API.
- Users: Developers and technical professionals who want a small local-first CLI workflow.
- Primary outcome: `meetxt record meeting.wav` creates local audio that `meetxt transcribe meeting.wav` converts to Markdown, with safe actionable errors at either step.

## Repository

- Main stack: Ruby 3.3 gem with a `meetxt` executable.
- Tooling: Bundler, RSpec, RuboCop, and GitHub Actions.
- Commands: `bundle install`; run with `bundle exec exe/meetxt`; test with `bundle exec rspec`; lint with `bundle exec rubocop`; build with `gem build meetxt.gemspec`. Typecheck is not applicable for the MVP.
- Boundary: CLI → macOS recording orchestrator, or CLI → transcription service → OpenAI adapter → Markdown renderer → atomic file writer.

## Constraints

- MVP records WAV through local FFmpeg/AVFoundation and accepts local MP3, M4A, and WAV files on macOS.
- `OPENAI_API_KEY` is the only required configuration.
- Audio goes to OpenAI; MeetXT retains no uploaded copy or intermediate data.
- Existing outputs are never overwritten.
- Keys, transcript content, and raw API bodies are never logged or exposed by default.
- Keep runtime dependencies minimal and provider code isolated.
