#!/usr/bin/env bash
set -euo pipefail
printf '\n== identity ==\n'; id
printf '\n== host ==\n'; hostnamectl --static 2>/dev/null || hostname
printf '\n== kernel ==\n'; uname -r
printf '\n== uptime ==\n'; uptime
printf '\n== memory ==\n'; free -h
printf '\n== filesystems ==\n'; df -hT
printf '\n== addresses ==\n'; ip -br addr
printf '\n== routes ==\n'; ip route
printf '\n== listeners ==\n'; ss -lntup
printf '\n== failed services ==\n'; systemctl --failed --no-legend || true
