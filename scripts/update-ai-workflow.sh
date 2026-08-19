#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT" ]]; then
  echo "error: run update from inside a Git repository" >&2
  exit 1
fi

old_revision="$(git -C "$ROOT" rev-parse HEAD:.ai-template 2>/dev/null || printf 'unknown')"

git -C "$ROOT" submodule update --init --remote .ai-template
"$ROOT/scripts/setup-ai-workflow.sh"

new_revision="$(git -C "$ROOT/.ai-template" rev-parse HEAD 2>/dev/null || printf 'unknown')"
printf 'AI workflow revision: %s -> %s\n' "$old_revision" "$new_revision"
printf 'Review the change and commit .ai-template explicitly when ready.\n'
