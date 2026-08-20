#!/usr/bin/env bash
set -euo pipefail

adapter_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

fixture_repo="$tmp_root/fake-ai-project-template"
project="$tmp_root/project"
missing_config="$tmp_root/missing-config"

cp -a "$adapter_root/tests/fixtures/fake-ai-project-template" "$fixture_repo"
mkdir -p "$fixture_repo/.agents/skills/project-intake" "$fixture_repo/.cursor/commands" "$fixture_repo/.ai/project"
printf '%s\n' '---' 'name: project-intake' 'description: test adapter' '---' > "$fixture_repo/.agents/skills/project-intake/SKILL.md"
printf '# /execute-goal\n\nDelegate to `.ai/skills/execute-goal.md`.\n' > "$fixture_repo/.cursor/commands/execute-goal.md"
printf 'template-owned\n' > "$fixture_repo/.ai/project/template-only.md"
git -C "$fixture_repo" init -q
git -C "$fixture_repo" config user.email test@example.com
git -C "$fixture_repo" config user.name Test
git -C "$fixture_repo" add .
git -C "$fixture_repo" commit -qm initial

mkdir -p "$project/scripts" "$project/.ai/project"
cp "$adapter_root/scripts/setup-ai-workflow.sh" "$project/scripts/"
cp "$adapter_root/scripts/check-workflow-leak.sh" "$project/scripts/"
cp "$adapter_root/scripts/ai-workflow-doctor.sh" "$project/scripts/"
cp "$adapter_root/scripts/update-ai-workflow.sh" "$project/scripts/"
cp "$adapter_root/.gitignore" "$project/.gitignore"
cat > "$project/.ai/project/product-context.md" <<'DOC'
# Product Context
project-owned
DOC

git -C "$project" init -q
git -C "$project" config user.email test@example.com
git -C "$project" config user.name Test
git -C "$project" add scripts .gitignore .ai/project/product-context.md
git -C "$project" commit -qm base

git -C "$project" -c protocol.file.allow=always submodule add -q "$fixture_repo" .ai-template
git -C "$project" commit -qam 'add submodule'

assert_contains() {
  [[ "$1" == *"$2"* ]] || { printf 'Expected output to contain: %s\nActual: %s\n' "$2" "$1" >&2; exit 1; }
}

printf '1. setup initializes an uninitialized submodule\n'
git -C "$project" submodule deinit -q -f .ai-template
GIT_ALLOW_PROTOCOL=file "$project/scripts/setup-ai-workflow.sh" >/dev/null
[[ -f "$project/.ai-template/.ai/README.md" ]]

printf '2. materializes private workflow\n'
[[ -f "$project/.ai/automation/project-executor.md" ]]
[[ -f "$project/.ai/policies/private-rule.md" ]]

printf '3. preserves tracked project overlay\n'
grep -q 'project-owned' "$project/.ai/project/product-context.md"

printf '4. preserves uncommitted overlay edits\n'
printf '# Product Context\nuncommitted-edit\n' > "$project/.ai/project/product-context.md"
(cd "$project" && GIT_ALLOW_PROTOCOL=file ./scripts/setup-ai-workflow.sh >/dev/null)
grep -q 'uncommitted-edit' "$project/.ai/project/product-context.md"
git -C "$project" checkout -- .ai/project/product-context.md

printf '5. removes stale template-owned files\n'
printf 'stale\n' > "$project/.ai/stale-private.md"
(cd "$project" && GIT_ALLOW_PROTOCOL=file ./scripts/setup-ai-workflow.sh >/dev/null)
[[ ! -e "$project/.ai/stale-private.md" ]]

printf '6. repeated setup is idempotent\n'
first="$(cd "$project" && GIT_ALLOW_PROTOCOL=file ./scripts/setup-ai-workflow.sh)"
second="$(cd "$project" && GIT_ALLOW_PROTOCOL=file ./scripts/setup-ai-workflow.sh)"
assert_contains "$first" 'AI workflow ready'
assert_contains "$second" 'AI workflow ready'

printf '7. project definition files are not ignored while other materialized files stay ignored\n'
for path in \
  .ai/project/vision.md \
  .ai/project/scope.md \
  .ai/project/glossary.md \
  .ai/docs/project-requirements.md; do
  if git -C "$project" check-ignore -q "$path"; then
    echo "project definition file is unexpectedly ignored: $path" >&2
    exit 1
  fi
done
git -C "$project" check-ignore -q .ai/project/template-only.md

printf '8. leak check passes for clean project\n'
(cd "$project" && ./scripts/check-workflow-leak.sh >/dev/null)

printf '9. leak check rejects tracked private workflow\n'
git -C "$project" add -f .ai/policies/private-rule.md
set +e
leak_output="$(cd "$project" && ./scripts/check-workflow-leak.sh 2>&1)"
leak_status=$?
set -e
[[ "$leak_status" -ne 0 ]]
assert_contains "$leak_output" 'private/materialized AI workflow file is tracked'
git -C "$project" reset -q .ai/policies/private-rule.md

printf '10. doctor reports ready after setup\n'
doctor_output="$(cd "$project" && ./scripts/ai-workflow-doctor.sh)"
assert_contains "$doctor_output" 'Status: ready'

printf '11. setup works from nested directory\n'
mkdir -p "$project/nested/deeper"
(cd "$project/nested/deeper" && GIT_ALLOW_PROTOCOL=file ../../scripts/setup-ai-workflow.sh >/dev/null)

printf '12. missing submodule configuration fails closed\n'
mkdir -p "$missing_config/scripts"
cp "$adapter_root/scripts/setup-ai-workflow.sh" "$missing_config/scripts/"
git -C "$missing_config" init -q
set +e
missing_output="$(cd "$missing_config" && ./scripts/setup-ai-workflow.sh 2>&1)"
missing_status=$?
set -e
[[ "$missing_status" -ne 0 ]]
assert_contains "$missing_output" '.gitmodules is missing'

printf '13. setup updates the private workflow from the configured remote\n'
printf 'updated\n' > "$fixture_repo/.ai/updated-by-setup.md"
git -C "$fixture_repo" add .ai/updated-by-setup.md
git -C "$fixture_repo" commit -qm 'update workflow'
latest_revision="$(git -C "$fixture_repo" rev-parse HEAD)"
(cd "$project" && GIT_ALLOW_PROTOCOL=file ./scripts/setup-ai-workflow.sh >/dev/null)
checked_out_revision="$(git -C "$project/.ai-template" rev-parse HEAD)"
[[ "$latest_revision" == "$checked_out_revision" ]]
[[ -f "$project/.ai/updated-by-setup.md" ]]

printf '14. legitimate adapter filenames do not trigger leak detection\n'
mkdir -p "$project/.cursor/rules"
printf 'adapter\n' > "$project/.cursor/rules/ai-project-template.mdc"
git -C "$project" add .cursor/rules/ai-project-template.mdc
git -C "$project" commit -qm 'add legitimate adapter filename'
(cd "$project" && ./scripts/check-workflow-leak.sh >/dev/null)

printf '15. root-level private repository copy is rejected\n'
mkdir -p "$project/ai-project-template/.ai/policies"
printf 'private\n' > "$project/ai-project-template/.ai/policies/copied.md"
git -C "$project" add -f ai-project-template/.ai/policies/copied.md
set +e
copied_output="$(cd "$project" && ./scripts/check-workflow-leak.sh 2>&1)"
copied_status=$?
set -e
[[ "$copied_status" -ne 0 ]]
assert_contains "$copied_output" 'copied private ai-project-template repository is tracked'

printf '16. setup materializes Codex and Cursor adapters\n'
[[ -f "$project/.agents/skills/project-intake/SKILL.md" ]]
[[ -f "$project/.cursor/commands/execute-goal.md" ]]
[[ -z "$(git -C "$project" status --porcelain -- .agents/skills .cursor/commands)" ]]

printf 'All adapter contract tests passed.\n'
