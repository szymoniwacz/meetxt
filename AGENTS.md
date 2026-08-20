# Agent Instructions

MeetXT is a planned Ruby 3.3 command-line application for turning local meeting audio into timestamped Markdown transcripts. Product implementation must follow the requirements and readiness gates in `.ai/`.

The repository uses a private reusable AI workflow through the `.ai-template` submodule. If `.ai/README.md` is unavailable, run `./scripts/setup-ai-workflow.sh` first. If the private workflow cannot be loaded, stop rather than inventing replacement workflow rules.

After setup, `.ai/` is the source of truth for workflow, policies, skills, review rules, Git rules, automation instructions, and project context. Read `.ai/README.md`, `.ai/project/product-context.md`, `.ai/project/scope.md`, and `.ai/docs/project-requirements.md` before product work. For end-to-end goals, follow `.ai/skills/execute-goal.md`.

Project-specific context is tracked in `.ai/` as an overlay and must not be overwritten by reusable workflow updates. Use the active Ruby CLI stack profile at `.ai/stack-profiles/ruby-cli.md`.

Do not invent setup, test, lint, build, or run commands before the real Ruby CLI scaffold exists. Do not implement product behavior unless the requested goal is implementation-ready. Keep OpenAI-specific code behind the planned provider adapter, never commit secrets or meeting recordings, and do not make paid provider calls in automated tests or CI.
