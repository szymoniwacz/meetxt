# ai-project-template-adapter

Public GitHub template for using the private `szymoniwacz/ai-project-template` workflow without publishing its reusable workflow files.

## How it works

```text
target repository
      |
      v
.ai-template/                 private git submodule
      |
      v
./scripts/setup-ai-workflow.sh
      |
      v
.ai/                          runtime source of truth
      |
      +-- private reusable workflow
      +-- tracked project-specific overlay
```

The repository pins one exact private workflow revision through the `.ai-template` gitlink. Setup materializes the private `.ai/` tree locally and restores project-owned tracked `.ai/**` files over it.

Private workflow files may exist in the working tree, but they must never be committed to a public target repository.

## Create a project

After creating a repository from this template and cloning it:

```bash
./scripts/setup-ai-workflow.sh
```

The script initializes `.ai-template` when necessary. Your GitHub identity or automation environment must have read access to `szymoniwacz/ai-project-template`.

Then customize the tracked project context under:

```text
.ai/project/
```

After setup, agents should read `.ai/README.md` and treat `.ai/` as the workflow source of truth.

## Check the connection

```bash
./scripts/ai-workflow-doctor.sh
```

A ready repository ends with:

```text
Status: ready
```

## Prevent workflow leaks

```bash
./scripts/check-workflow-leak.sh
```

The check allows private workflow files to exist locally after setup, but fails if reusable materialized workflow files are tracked outside the project-owned overlay allowlist.

## Update the private workflow

```bash
./scripts/update-ai-workflow.sh
```

The update is explicit: the script moves the submodule checkout to the configured remote revision and rematerializes `.ai/`, but it does not commit anything. Review the `.ai-template` gitlink change before committing it.

## Cloud automation

Public loaders live under:

```text
docs/ai-workflow/project-executor-loader.md
docs/ai-workflow/goal-executor-loader.md
```

They contain no private executor logic. They only require the automation environment to obtain the private submodule, materialize `.ai/`, and then delegate to the private runtime.

Automation credentials belong in the provider's runtime/secret configuration, never in this repository.

See `docs/automation-setup.md` for the integration contract.

## Tests

```bash
bash tests/test-adapter.sh
```

Tests use a local fake private workflow fixture. CI never requires access to the real private repository.

## Design

- `docs/repository-specification.md` — source-of-truth architecture and invariants.
- `docs/setup.md` — target repository setup and workflow updates.
- `docs/automation-setup.md` — cloud automation integration.

## Security model

Someone without access to `szymoniwacz/ai-project-template` may see the repository URL and pinned submodule commit, but cannot fetch the private workflow contents. Setup fails closed when the private workflow cannot be loaded.

## License

MIT
