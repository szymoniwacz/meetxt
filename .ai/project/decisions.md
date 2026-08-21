# Project Decisions

## Decisions

### 2026-08-20 — File-based MVP

- Accept existing MP3, M4A, and WAV files on macOS; defer recording.
- Write same-directory Markdown with the source basename; never overwrite.

### 2026-08-20 — OpenAI provider boundary

- Use OpenAI via `OPENAI_API_KEY`.
- For the MVP, use `whisper-1` with `response_format: verbose_json` and segment timestamps.
- Prefer the official Ruby SDK when compatible with a small adapter.
- Make one request per input/execution unless provider-required; do not retry automatically.
- Do not build a speculative generic provider framework.

### 2026-08-20 — Stack and architecture

- Ruby 3.3 gem/executable; Bundler, RSpec, RuboCop, no static typing.
- Responsibilities: CLI, transcription service, provider adapter, renderer, file writer.
- Prefer standard Ruby and minimal runtime dependencies.

### 2026-08-20 — Privacy boundary

- Persist only the user input and final transcript.
- Never expose keys, transcript text, or raw provider bodies in logs/default errors.
- Sanitize provider failures; document external upload and user legal responsibility.

### 2026-08-20 — Project delivery

- MIT-licensed open-source personal project maintained by Szymon Iwacz.
- Feature branches and PRs to `main`; GitHub Actions required before merge.
- No automatic release; define manual RubyGems publication/rollback at first release.
