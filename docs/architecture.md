# Architecture

The adapter uses one integration model everywhere:

```text
private ai-project-template
        |
        v
.ai-template git submodule (pinned revision)
        |
        v
setup-ai-workflow.sh
        |
        v
.ai/ runtime
        |
        +-- private reusable workflow
        +-- tracked project overlay
```

`.ai-template` is upstream workflow source. `.ai/` is runtime source of truth. Tracked `.ai/**` files are project-owned overlay; materialized reusable files remain untracked.

Local agents and cloud automations therefore consume the same path layout. Public agent adapters and automation loaders contain connection instructions only. Reusable workflow behavior remains exclusively in the private repository.

See `docs/repository-specification.md` for the complete contract and invariants.
