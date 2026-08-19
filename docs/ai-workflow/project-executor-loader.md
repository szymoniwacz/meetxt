# Project Executor — Public Loader

This file is a public loader only. It does not implement Project Executor behavior.

Before any repository mutation or remote write:

1. Resolve the target repository default branch and current workspace.
2. Ensure the private `.ai-template` submodule is available in the workspace. If it is not initialized, run `./scripts/setup-ai-workflow.sh` when the environment permits it.
3. If private workflow access or setup fails, make no repository mutation or remote write and report the blocker.
4. Verify `.ai/automation/project-executor.md` and `.ai/automation/goal-executor.md` exist after setup.
5. Read both files from the materialized `.ai/` runtime.
6. Follow `project-executor.md` for orchestration and `goal-executor.md` for delegated goals.
7. Do not infer, duplicate, or replace private executor rules from this loader.

The automation environment must have read access to `szymoniwacz/ai-project-template`. Credentials belong in the automation provider's runtime/secret configuration and must never be committed.
