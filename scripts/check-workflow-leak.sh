#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git -C "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT" ]]; then
  echo "error: run leak check from inside a Git repository" >&2
  exit 1
fi

is_project_owned() {
  case "$1" in
    .ai/project/*|.ai/docs/project-requirements.md|.ai/docs/architecture-direction.md|.ai/architecture/adr-*.md|.ai/stack-profiles/*|.ai/ideas/*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

failed=0
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  if ! is_project_owned "$path"; then
    echo "error: private/materialized AI workflow file is tracked: $path" >&2
    failed=1
  fi
done < <(git -C "$ROOT" ls-files -- .ai)

if git -C "$ROOT" ls-files --stage -- .ai-template | grep -q .; then
  mode="$(git -C "$ROOT" ls-files --stage -- .ai-template | awk 'NR==1 {print $1}')"
  if [[ "$mode" != "160000" ]]; then
    echo "error: .ai-template must be a git submodule (mode 160000)" >&2
    failed=1
  fi
fi

# A real submodule is represented by the single .ai-template gitlink. Files
# below .ai-template must never be tracked by the target repository itself.
if git -C "$ROOT" ls-files -- '.ai-template/*' | grep -q .; then
  echo "error: files below .ai-template are tracked outside the submodule gitlink" >&2
  failed=1
fi

# Reject an obvious root-level copy of the private repository, while allowing
# legitimate adapter names such as ai-project-template.mdc and test fixtures.
if git -C "$ROOT" ls-files -- 'ai-project-template/*' | grep -q .; then
  echo "error: copied private ai-project-template repository is tracked" >&2
  failed=1
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "Workflow leak check: clean"
