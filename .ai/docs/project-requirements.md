# Project Requirements

## Project summary

MeetXT is a local-first Ruby 3.3 CLI for developers and technical professionals who want searchable, reviewable meeting records without a platform integration or bot. It sends an existing recording to OpenAI and writes a timestamped Markdown transcript locally.

The first version succeeds when `meetxt transcribe meeting.mp3` reliably produces `meeting.md` from a real meeting and reports clear, sanitized errors for configuration, input, network, provider, rate-limit, and file-write failures.

## Users

| User | Needs | Notes |
|---|---|---|
| Developer or technical professional | Small scriptable audio-to-transcript workflow | Comfortable with CLI and environment variables |

## Problems to solve

- Audio alone is hard to search, review, and reuse.
- Existing workflows may require bots, integrations, accounts, or large hosted products.
- Failures must be actionable without leaking meeting or credential data.

## Goals

- Create readable timestamped Markdown with one command.
- Isolate provider details from the CLI/core flow.
- Validate locally and protect existing output before upload.
- Make API usage predictable: one request per input/execution unless provider-required.
- Support gem installation and direct repository development.

## Non-goals

- Recording, GUI/web UI, bots, platform/calendar integrations, diarization, summaries/actions, cloud storage, or accounts.
- Configurable model/language, retries, output overrides, unique naming, Linux, static typing, release automation, or a generic provider framework.

## Core workflows

### Transcribe a meeting

1. User exports `OPENAI_API_KEY` and runs `meetxt transcribe meeting.mp3`.
2. MeetXT validates input and target before any API call.
3. It uploads once, renders provider segments, and atomically creates `meeting.md`.
4. It prints only the created path to stdout and exits successfully.

### Handle failure

1. Classify local validation, configuration/authentication, rate-limit, provider/server, network, or file-write failure.
2. Print a concise sanitized error to stderr and exit nonzero.
3. Do not overwrite, leave partial output, retry, or repeat upload in that execution.

### Discover usage

`meetxt --help` and `meetxt --version` succeed. Missing/invalid commands show concise usage and exit nonzero.

## Functional requirements

| ID | Requirement | Priority | Notes |
|---|---|---|---|
| FR-001 | Provide `meetxt transcribe <audio-file>`. | must | MVP command |
| FR-002 | Accept MP3/M4A/WAV; reject other extensions before API access. | must | macOS initially |
| FR-003 | Reject missing, empty, and unreadable inputs locally. | must | Useful local path allowed in error |
| FR-004 | Require `OPENAI_API_KEY`; never echo it. | must | Only MVP configuration |
| FR-005 | Make one transcription request per input/execution unless provider-required; no retry. | must | Predictable cost |
| FR-006 | Select one model in code and let the provider auto-detect spoken language. | must | No user model/language setting |
| FR-007 | Isolate OpenAI behind one small adapter. | must | No generic framework |
| FR-008 | Default `meeting.mp3` output to adjacent `meeting.md`. | must | No override yet |
| FR-009 | Refuse existing output before upload. | must | No overwrite or duplicate cost |
| FR-010 | Atomically write complete UTF-8 output; leave no partial file. | must | No API retry after write failure |
| FR-011 | Floor fractional segment starts and render `[HH:MM:SS]`, always including hours. | must | Provider-supported timestamps |
| FR-012 | Include title, source, ISO-8601 local transcription time with offset, provider, optional model, and transcript. | must | Duration only if readily available |
| FR-013 | Preserve provider text except minimal structure; one blank line between segments. | must | Human-readable |
| FR-014 | Distinguish validation, overwrite, auth/config, rate-limit, provider, network, and write errors. | must | Sanitized/actionable |
| FR-015 | Success: path only on stdout/zero; error: stderr/nonzero conventional code. | must | Quiet normal output |
| FR-016 | Provide `--help`/`--version`; concise nonzero usage for missing/invalid commands. | must | Standard CLI behavior |

## Data and inputs

| Input | Source | Format | Notes |
|---|---|---|---|
| Meeting recording | Local filesystem | MP3, M4A, WAV | Normal meetings up to ~2 hours; provider constraints apply |
| Credential | Environment | `OPENAI_API_KEY` | Required and secret |

## Outputs

| Output | Consumer | Format | Notes |
|---|---|---|---|
| Transcript | User/local tools | UTF-8 Markdown | Adjacent, same basename, never overwrite |
| Created path | Shell/user | stdout line | Success only |
| Error | Shell/user | stderr | Sanitized plus nonzero exit |

```markdown
# meeting

- Source: meeting.mp3
- Transcribed: 2026-08-20T09:22:00+02:00
- Provider: OpenAI Whisper
- Model: <model name when available>

## Transcript

[00:00:12] First transcript segment...

[00:00:27] Next transcript segment...
```

## Integrations

| Integration | Purpose | Required now? | Notes |
|---|---|---|---|
| OpenAI transcription API | Timestamped transcription | Yes | Prefer official SDK; adapter; sanitized errors; no retries |

## Constraints

- Ruby 3.3 and macOS initially; avoid needless OS coupling.
- Gem install plus direct repository execution.
- Straightforward processing; no latency SLA; normal recordings up to ~2 hours subject to provider limits.
- Do not hard-code a provider size limit unless exposed as a stable documented SDK limit.
- Persist no uploaded copy or intermediate provider data.

## Technical preferences

- Bundler; official OpenAI Ruby SDK when boundary-friendly.
- CLI, service, adapter, renderer, and writer with small explicit responsibilities.
- RSpec, RuboCop, no static typing, standard library where practical, minimal runtime dependencies.

## Active stack profile

No existing profile exactly fits a Ruby CLI. Selection or creation during bootstrap blocks readiness, not definition coverage.

| Active profile | Applies to | Notes |
|---|---|---|
| Not yet selected | Ruby 3.3 CLI/gem | Do not substitute the Rails profile; resolve during bootstrap |

## Quality requirements

- Unit tests for core services/rendering; mocked provider-adapter tests; CLI success/major-error integration tests.
- Cover overwrite protection and atomic writes.
- No paid OpenAI calls in CI; optional manual real-provider smoke test.
- RuboCop and GitHub Actions required before merge.

## Security and privacy requirements

- Never expose keys, transcript content, or raw API bodies in logs/default errors.
- Sanitize provider errors; useful local filenames/paths may appear.
- Persist no uploaded copy/intermediate data; document external upload.
- Document that users own recording/upload permission and confidentiality, privacy, and legal compliance. Do not enforce consent in code.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Provider/SDK changes | API or timestamps break | Adapter plus mapped-response/error tests |
| Upload succeeds, write fails | Cost without saved transcript | Validate first, atomic write, clear error, no retry |
| Sensitive error leakage | Privacy/credential exposure | Sanitization rules and tests |
| Provider rejects large/long input | Meeting fails after upload begins | Clear provider error; document dependency |
| Timestamp response differs | Acceptance format unavailable | Choose timestamp-capable model/response before implementation |
| macOS coupling | Linux work becomes costly | Prefer portable Ruby behavior |

## Assumptions

| Assumption | Why it matters | Confirm by |
|---|---|---|
| User owns retention, backup, and deletion of local audio/transcripts. | No application data lifecycle exists. | Bootstrap documentation review |
| MeetXT has no telemetry or persistent app log. | Preserves privacy and MVP simplicity. | First implementation plan |
| Provider segments supply useful timing. | Timestamps are mandatory. | SDK investigation and smoke test |
| Exact default model is chosen from currently supported timestamp-capable models. | Availability may change; user does not configure it. | Resolve before implementation-ready and record decision |

## Open questions

- [ ] Exact OpenAI model/response format: resolve during technical planning before implementation-ready.
- [ ] Ruby CLI stack profile and real commands: resolve during template customization.
- [ ] Manual RubyGems publication/rollback: resolve when preparing the first release.

These are deferred with explicit return triggers and do not block definition coverage.

## First useful version

On macOS with Ruby 3.3 and `OPENAI_API_KEY`, `meetxt transcribe meeting.mp3` creates complete readable timestamped `meeting.md`, or safely reports a defined failure without overwrite, partial output, sensitive leakage, or unintended repeat calls.

## Later versions

Consider recording, Linux, output overrides, unique naming, alternate providers, retries, diarization, summaries/actions, integrations, and other interfaces only after file transcription is reliable. Define publishing when preparing the first release.

## Project decision status

| Area | Status | Value / notes | Link / location / return trigger |
|---|---|---|---|
| Product purpose | decided | Local meeting audio to timestamped Markdown | Summary; `.ai/project/vision.md` |
| Users | decided | Developers/technical professionals using a CLI | Users; `.ai/project/product-context.md` |
| Outcomes | decided | One command creates transcript or safe actionable error | Goals; First useful version |
| Success criteria | decided | Real meeting produces timestamped Markdown; defined failures pass tests | First useful version; FRs |
| First useful version | decided | File transcription via OpenAI on macOS | First useful version; scope |
| Non-goals | decided | Explicit deferred feature set | Non-goals; `.ai/project/scope.md` |
| Interfaces | decided | CLI commands, Markdown file, stdout/stderr | Workflows; FR-001/15/16 |
| Inputs and outputs | decided | MP3/M4A/WAV + key in; Markdown/path/error out | Data and inputs; Outputs |
| Architecture shape | decided | CLI → service → adapter → renderer → writer | Technical preferences; decisions |
| Boundaries | decided | MeetXT coordinates/writes; OpenAI transcribes; user owns files/compliance | Constraints; privacy |
| Storage and data ownership | decided | User-owned local input/final transcript only | Privacy requirements |
| Retention and migrations | not-applicable | No managed store/schema/retention/migrations | Confirmed intake; user manages files |
| Integrations and failure handling | decided | OpenAI only; no retry; categorized sanitized failure | Integrations; Workflow 2 |
| Authentication and authorization | not-applicable | No app accounts/permissions; only provider key | FR-004; confirmed intake |
| Secrets, privacy, and sensitive data | decided | Redaction, no content/raw bodies, upload disclosure | Privacy requirements |
| Language, framework, and dependencies | decided | Ruby 3.3 gem, Bundler/RSpec/RuboCop, minimal deps, no typing | Technical preferences; decisions |
| Environments and deployment | not-applicable | Local CLI; no staging/production | Confirmed intake |
| Configuration | decided | `OPENAI_API_KEY`; fixed model; auto language | FR-004/006 |
| Logging, monitoring, and errors | decided | Quiet stdout; sanitized stderr; no telemetry/log assumed | FR-014/015; assumptions |
| Tests, lint, typecheck, performance | decided | RSpec, RuboCop, mocked CI, manual smoke, no typing/SLA | Quality requirements |
| Scale, reliability, and cost | decided | ~2-hour meetings, one call/input/execution, atomic output, no retry | Constraints; FR-005/010 |
| Supported platforms and compatibility | decided | Ruby 3.3/macOS; MP3/M4A/WAV; portability favored | Constraints; FR-002 |
| Accessibility and localization | not-applicable | English terminal/docs; readable output; spoken language auto-detected | Confirmed intake; FR-006 |
| Compliance, backup, and recovery | not-applicable | User owns consent/legal duties and local backup/recovery | Privacy requirements; confirmed intake |
| Branching, CI, release, and rollback | decided | Feature PRs to `main`, required GitHub Actions, manual revert/yank, release details deferred until first release | Decisions; Quality requirements |
| License, ownership, and documentation expectations | decided | MIT; maintained by Szymon Iwacz; upload/legal docs required | Decisions; Privacy requirements |

## Project readiness

Readiness was not approved by intake. Complete `.ai/onboarding/bootstrap-checklist.md`; do not implement until the final row is confirmed.

| Check | Result | Notes |
|---|---|---|
| Definition coverage complete | yes | All contract areas explicitly classified |
| No `blocking-question` remains | yes | Deferred details have return triggers |
| All `deferred` items have reason and return trigger | yes | Model before implementation; stack/commands at bootstrap; publishing at first release |
| Template customization complete | not assessed | Bootstrap not run |
| Stack profile selected or marked N/A | no | Ruby CLI profile unresolved |
| Real project commands recorded | no | Establish from actual scaffold |
| Root README describes the product | not assessed | Bootstrap not run |
| `AGENTS.md` describes repository role | not assessed | Bootstrap not run |
| Bootstrap markers removed | not assessed | Bootstrap not run |
| License and ownership decided | yes | MIT; Szymon Iwacz |
| CI, branch rules, and approvals decided | yes | GitHub Actions required for PRs to `main` |
| Project ready for first product task | no | Customization/readiness checks remain |
