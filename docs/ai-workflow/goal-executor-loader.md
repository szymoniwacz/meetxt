# Goal Executor — Public Loader

This file is a public loader only. It does not implement Goal Executor behavior.

Before any repository mutation or remote write:

1. Resolve the target repository default branch and current workspace.
2. Ensure the private `.ai-template` submodule is available in the workspace. If it is not initialized, run `./scripts/setup-ai-workflow.sh` when the environment permits it.
3. If private workflow access or setup fails, make no repository mutation or remote write and report the blocker.
4. Verify `.ai/automation/goal-executor.md` exists after setup.
5. Read `.ai/automation/goal-executor.md` from the materialized `.ai/` runtime together with every private workflow document it requires.
6. Follow that runtime exactly.
7. Do not infer, duplicate, or replace private executor rules from this loader.

The automation environment must have read access to `szymoniwacz/ai-project-template`. Credentials belong in the automation provider's runtime/secret configuration and must never be committed.
