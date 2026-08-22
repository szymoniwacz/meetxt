# Scope

## In scope now

- Ruby 3.3 gem/CLI, runnable after installation or from the repository.
- `meetxt record <output.wav>` using the default macOS audio input through local FFmpeg, stopped explicitly with Enter.
- `meetxt transcribe <audio-file>` for MP3, M4A, and WAV on macOS.
- Pre-upload validation of extension, existence, readability, non-empty content, and output collision.
- One OpenAI transcription request through a small provider adapter.
- UTF-8 Markdown beside the input, timestamped as `[HH:MM:SS]`, written atomically without overwrite.
- Sanitized categorized errors, conventional exit behavior, `--help`, and `--version`.
- RSpec tests, RuboCop, and GitHub Actions without paid CI calls.
- Documentation of external upload and user consent/legal responsibility.

## Out of scope for the first useful version

- Configurable recording devices; combined record-and-transcribe; GUI/web UI; meeting bots; Zoom, Teams, Meet, or calendar integrations.
- Diarization, summaries, action extraction, cloud storage, accounts, or app authentication.
- Output overrides/unique naming, configurable models/languages, or automatic retries.
- Linux support, static typing, generalized provider framework, or release automation.
- App-managed backups, migrations, staging, or production environments.

## Rule

Later capabilities require an explicit scope update. Product work must pass `.ai/quality/definition-of-ready.md` first.
