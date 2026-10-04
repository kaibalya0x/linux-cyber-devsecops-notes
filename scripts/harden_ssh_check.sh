#!/usr/bin/env bash
set -euo pipefail
if ! command -v sshd >/dev/null 2>&1; then
  echo "sshd is not installed or not in PATH" >&2
  exit 1
fi
sshd -t
printf '%-28s %s\n' "Setting" "Effective value"
for key in PermitRootLogin PasswordAuthentication PubkeyAuthentication MaxAuthTries X11Forwarding AllowUsers AllowGroups; do
  value=$(sshd -T 2>/dev/null | awk -v k="$key" '$1==tolower(k){$1=""; sub(/^ /,""); print; exit}')
  printf '%-28s %s\n' "$key" "${value:-<not-set-or-default> }"
done
