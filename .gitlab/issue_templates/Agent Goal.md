<!--
Describe the outcome you want. Do not provide file names, architecture, or an
implementation plan.

Leave the Commands section at the bottom as-is so it stays visible on the
created issue. Agents ignore it for scope.
-->

## Goal

<!-- What outcome should this work achieve? Use one clear goal statement. -->

## Acceptance criteria

<!-- How will you know the work is done? List observable outcomes. -->

## Constraints

<!-- Optional: boundaries, dependencies, or non-negotiable limits. -->

## Out of scope

<!-- Optional: work that must not be included in this goal. -->

## Relevant context

<!-- Optional: links, prior decisions, or background the agent should read. -->

## Commands

REFERENCE ONLY — agents must ignore this entire section for scope, planning,
implementation, validation, and Done.

Comment exactly one option (repository owner):

- `/execute-goal` — default: authorize work through a review-ready MR (human CR, then you merge)
- `/execute-goal self-correcting-review` — same + self-correcting review mode when eligible (skip human CR; you still merge)
- `/execute-goal self-correcting-review auto-merge` — same + Goal Executor squash-merges when eligible

Authorizes branch, scoped changes, validation, commits, push, MR, GitLab CI
stabilization, and handoff. Merge only with the `auto-merge` form when eligible.

Details: `.ai/policies/autonomy-and-authorization.md`,
`.ai/review/self-correcting-review-loop.md`
