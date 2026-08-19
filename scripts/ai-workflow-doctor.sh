#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT" ]]; then
  echo "Status: not ready"
  echo "FAIL repository root"
  exit 1
fi

failures=0
check() {
  local message="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS $message"
  else
    echo "FAIL $message"
    failures=$((failures + 1))
  fi
}

check ".gitmodules defines .ai-template" git -C "$ROOT" config -f .gitmodules --get-regexp '^submodule\.\.ai-template\.path$'
check ".ai-template is initialized" test -f "$ROOT/.ai-template/.ai/README.md"
check "Project Executor exists" test -f "$ROOT/.ai-template/.ai/automation/project-executor.md"
check "Goal Executor exists" test -f "$ROOT/.ai-template/.ai/automation/goal-executor.md"
check "materialized .ai/README.md exists" test -f "$ROOT/.ai/README.md"
check "project overlay exists" test -f "$ROOT/.ai/project/product-context.md"

if "$ROOT/scripts/check-workflow-leak.sh" >/dev/null 2>&1; then
  echo "PASS workflow leak check"
else
  echo "FAIL workflow leak check"
  failures=$((failures + 1))
fi

if [[ -d "$ROOT/.ai-template/.git" || -f "$ROOT/.ai-template/.git" ]]; then
  revision="$(git -C "$ROOT/.ai-template" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
  echo "Workflow revision: $revision"
fi

if [[ "$failures" -eq 0 ]]; then
  echo "Status: ready"
else
  echo "Status: not ready"
  exit 1
fi
