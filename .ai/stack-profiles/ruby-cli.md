# Ruby CLI Stack Profile

Stack-specific guidance for MeetXT. Global workflow rules still apply.

## Runtime and packaging

- Target Ruby 3.3.
- Package MeetXT as a Ruby gem.
- Use Bundler for dependency management.
- Prefer standard Ruby libraries and minimal runtime dependencies.
- Keep packaging and executable files limited to what the implemented CLI requires.

## Project commands

```bash
bundle install
bundle exec exe/meetxt transcribe meeting.mp3
bundle exec rspec
bundle exec rubocop
bundle exec rake
gem build meetxt.gemspec
```

Static typechecking is not applicable to the MVP.

## Expected structure

The implemented first product slice uses these responsibility boundaries:

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
