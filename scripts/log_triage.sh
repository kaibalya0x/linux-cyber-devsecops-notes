#!/usr/bin/env bash
set -euo pipefail
SINCE="${1:-1 hour ago}"
printf '%s\n' "== warnings/errors since: $SINCE =="
journalctl --since "$SINCE" -p warning..alert --no-pager || true
printf '%s\n' "== recent SSH authentication events =="
journalctl -u ssh --since "$SINCE" --no-pager 2>/dev/null \
  | grep -Ei 'failed|accepted|invalid|authentication|session' \
  | tail -n 100 || true
printf '%s\n' "== active listening sockets =="
ss -lntup || true
