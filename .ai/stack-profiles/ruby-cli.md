# Ruby CLI Stack Profile

Stack-specific guidance for MeetXT. Global workflow rules still apply.

## Runtime and packaging

- Target Ruby 3.3.
- Package MeetXT as a Ruby gem.
- Use Bundler for dependency management.
- Prefer standard Ruby libraries and minimal runtime dependencies.
- Do not create packaging files or executable stubs during documentation-only bootstrap; create the real scaffold with the first product task.

## Project commands

No project setup, test, lint, build, or run commands are recorded yet because the Ruby application scaffold does not exist.

Record the real commands when the first product task creates the scaffold. Do not invent placeholder commands solely to satisfy readiness documentation.

## Expected structure

The first product task should establish only the structure it actually needs, following these responsibility boundaries:

- CLI
- transcription service
- OpenAI provider adapter
- Markdown renderer
- file writer

Do not create extra layers without a concrete need.

## Testing and quality

- Use RSpec for core services, Markdown rendering, mocked provider behavior, CLI behavior, and overwrite protection.
- Use RuboCop for Ruby style once the Ruby scaffold exists.
- Automated tests and CI must never make paid OpenAI calls.
- A real-provider smoke test is manual only.

## Security and integration constraints

- Never commit or print `OPENAI_API_KEY`.
- Never log transcript text or raw provider response bodies by default.
- Keep provider-specific behavior in one small adapter.
- Validate local files and output collisions before uploading audio.
