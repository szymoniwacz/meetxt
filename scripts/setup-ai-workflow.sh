#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT" ]]; then
  echo "error: run setup from inside a Git repository" >&2
  exit 1
fi

TEMPLATE="$ROOT/.ai-template"
AI="$ROOT/.ai"

if [[ ! -f "$ROOT/.gitmodules" ]]; then
  echo "error: .gitmodules is missing" >&2
  exit 1
fi

if ! git -C "$ROOT" config -f .gitmodules --get-regexp '^submodule\.\.ai-template\.path$' >/dev/null 2>&1; then
  echo "error: .gitmodules does not define .ai-template" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE/.ai/README.md" ]]; then
  if ! git -C "$ROOT" submodule update --init --recursive .ai-template; then
    echo "error: private AI workflow is unavailable" >&2
    echo "hint: ensure this environment can read szymoniwacz/ai-project-template" >&2
    exit 1
  fi
fi

required=(
  ".ai/README.md"
  ".ai/automation/project-executor.md"
  ".ai/automation/goal-executor.md"
  ".ai/instructions/workflow.md"
  ".ai/skills/execute-goal.md"
)
for path in "${required[@]}"; do
  if [[ ! -f "$TEMPLATE/$path" ]]; then
    echo "error: private AI workflow is invalid; missing $path" >&2
    exit 1
  fi
done

OVERLAY="$(mktemp -d)"
trap 'rm -rf "$OVERLAY"' EXIT

while IFS= read -r -d '' path; do
  source="$ROOT/$path"
  [[ -e "$source" || -L "$source" ]] || continue
  destination="$OVERLAY/$path"
  mkdir -p "$(dirname "$destination")"
  cp -a "$source" "$destination"
done < <(git -C "$ROOT" ls-files -z -- .ai)

mkdir -p "$AI"
rsync -a --delete "$TEMPLATE/.ai/" "$AI/"

if [[ -d "$OVERLAY/.ai" ]]; then
  rsync -a "$OVERLAY/.ai/" "$AI/"
fi

revision="$(git -C "$TEMPLATE" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
printf 'AI workflow ready under .ai/ (private template %s + project overlay)\n' "$revision"
