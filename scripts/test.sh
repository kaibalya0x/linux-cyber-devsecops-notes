#!/usr/bin/env bash
set -euo pipefail

# Lightweight repository smoke tests. No network access required.
[[ -f README.md ]]
[[ -d docs ]]
[[ -d scripts ]]
[[ -f RESEARCH.md ]]

for f in scripts/*.sh; do
  bash -n "$f"
done

count=$(find docs -maxdepth 1 -type f -name '*.md' | wc -l)
(( count >= 10 ))

echo "Repository smoke tests passed: ${count} documentation files."
