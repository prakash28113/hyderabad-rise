#!/usr/bin/env bash
set -euo pipefail
test "${GITHUB_REPOSITORY:?}" = prakash28113/hyderabad-rise
printf '%s  %s\n' 8ca1a322bad46380a7a2c06c52ea85d2cffc7e2780904d706c9d829bed136c69 Hyderabad-History.bundle | sha256sum -c -
git bundle verify Hyderabad-History.bundle
git clone --branch dev/sprint1-geographic-foundation Hyderabad-History.bundle restored
cd restored
test "$(git rev-parse HEAD)" = b37d08212336eac744bd227edb2dab36f54f260c
test "$(git rev-parse sprint1-original-3659f13)" = 3659f13ee634c64b1c475ed371f0ce21bec7ed3b
git merge-base --is-ancestor 3659f13 HEAD
git merge-base --is-ancestor 8526c48 HEAD
python3 -m unittest discover -s tests -v
python3 tools/validate_bundle.py
git remote set-url origin https://github.com/prakash28113/hyderabad-rise.git
gh auth setup-git --hostname github.com
# Existing refs must either be absent or match exactly. Never replace conflicts.
for ref in refs/heads/dev/sprint1-geographic-foundation refs/tags/sprint1-original-3659f13; do
  expected=$(git rev-parse "$ref")
  actual=$(git ls-remote origin "$ref" | cut -f1)
  if [ -n "$actual" ] && [ "$actual" != "$expected" ]; then
    printf 'Conflicting remote ref: %s\n' "$ref" >&2
    exit 1
  fi
done
git push --atomic origin refs/heads/dev/sprint1-geographic-foundation refs/tags/sprint1-original-3659f13
git ls-remote origin refs/heads/dev/sprint1-geographic-foundation refs/tags/sprint1-original-3659f13
