# Cloud Automation Setup

## Purpose

Cloud automation must use the same private workflow revision and the same materialized `.ai/` runtime as local agents. The public adapter never embeds Project Executor or Goal Executor logic.

## Required access

An automation run needs:

1. read/write access to the target repository as required by the private workflow,
2. read access to the private `szymoniwacz/ai-project-template` repository,
3. a workspace where the target repository can initialize its `.ai-template` submodule,
4. provider credentials stored as runtime secrets or equivalent external configuration.

Never commit a private-repository token, deploy key, or generated credential.

## Runtime bootstrap

At the beginning of a run, before any repository mutation or remote write:

1. read the appropriate public loader from the target repository default branch,
2. ensure `.ai-template` can be initialized,
3. run `./scripts/setup-ai-workflow.sh` when `.ai/README.md` is not already materialized,
4. verify the required private executor files exist under `.ai/automation/`,
5. delegate to the private executor runtime,
6. fail closed if any of the above cannot be completed.

Materialized private files under `.ai/` are workspace state only. Automation must not stage or commit them.

## Project Executor loader

Use:

```text
docs/ai-workflow/project-executor-loader.md
```

The saved/live automation prompt should remain a small loader that reads this public file from the target default branch, then follows it. Do not paste Project Executor state-machine logic into the public prompt.

## Goal Executor loader

Use:

```text
docs/ai-workflow/goal-executor-loader.md
```

Again, the public automation prompt loads the private runtime rather than duplicating it.

## Trigger configuration

The adapter deliberately does not duplicate private trigger, authorization, review, or merge rules.

After private workflow setup, use the production-setup documents materialized from `ai-project-template`, including the Project Executor and Goal Executor automation setup documents, as the source of truth for provider trigger configuration.

This keeps public loader behavior stable while the private workflow can evolve independently.

## Verification

Before enabling production automation for a generated repository:

1. run `./scripts/setup-ai-workflow.sh` locally,
2. run `./scripts/ai-workflow-doctor.sh`,
3. run `./scripts/check-workflow-leak.sh`,
4. configure the cloud environment with read access to the private submodule,
5. run a disposable automation invocation and verify the private runtime loads,
6. verify materialized `.ai/` files are not present in the resulting Git diff,
7. only then enable normal Project Executor / Goal Executor triggers.

## Failure behavior

Private workflow unavailable means STOP. The automation must not infer a replacement workflow from README files, public loaders, chat history, or previous runs.
