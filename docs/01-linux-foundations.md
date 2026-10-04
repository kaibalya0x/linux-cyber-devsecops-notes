# 01 — Linux Foundations That Matter in Security Work

## 1. The mental model

Linux is easier to troubleshoot when you stop thinking of it as “a bunch of commands” and instead see a few connected layers:

```
user → shell → process → syscall → kernel → hardware / network
                  |
                  +→ files, sockets, namespaces, cgroups
```

Security work is often about proving which layer is responsible for an observation.

Example: “the web server is down” is not yet a useful diagnosis. It could be:

- the process is not running;
- the process is running but not listening;
- the port is listening only on localhost;
- a firewall is dropping traffic;
- DNS resolves to the wrong host;
- the application accepts the connection but immediately crashes.

The command sequence below narrows those possibilities without guessing:

```bash
systemctl status nginx --no-pager
ss -lntp | grep ':80\b'
sudo nft list ruleset
curl -v http://127.0.0.1/
curl -v http://SERVER_IP/
getent hosts example.com
```

## 2. Navigation and discovery

The shell becomes much more useful when you treat it as a small investigation language.

```bash
pwd
ls -lah
find /var/log -maxdepth 2 -type f -name '*.log' 2>/dev/null
which ssh
command -v python3
whereis sshd
man 5 sshd_config
```

### Why `command -v` is worth learning

`which` is convenient, but shell built-ins, aliases, functions, and PATH ordering can make it misleading for investigation. `command -v` asks the shell how it resolves the command:

```bash
command -v cd
command -v ls
command -v ssh
```

For a security investigation, record the actual executable and its package ownership:

```bash
readlink -f "$(command -v ssh)"
dpkg -S "$(readlink -f "$(command -v ssh)")" 2>/dev/null || true
```

On RPM-based systems, the second command can be replaced with:

```bash
rpm -qf "$(readlink -f "$(command -v ssh)")"
```

## 3. Files are objects with metadata

A file is not just its contents. Start with:

```bash
ls -l /etc/passwd
stat /etc/passwd
file /usr/bin/ssh
```

Pay attention to:

- owner and group;
- permission bits;
- timestamps;
- size;
- file type;
- extended attributes where relevant.

### Symbolic vs hard links

```bash
ln -s /etc/hosts /tmp/hosts-link
ls -l /tmp/hosts-link
readlink -f /tmp/hosts-link

ln /etc/hosts /tmp/hosts-hardlink
ls -li /etc/hosts /tmp/hosts-hardlink
```

A hard link shares the same inode. A symbolic link stores a path. This difference matters when you are tracing unexpected file changes.

## 4. Shell expansion: the source of many mistakes

Before executing a command, understand what the shell will expand.

```bash
echo *.log
echo "$HOME"
echo '$HOME'
echo "$(id -un)"
```

The difference between single quotes and double quotes is security-relevant when a script handles untrusted input.

Bad habit:

```bash
rm -rf "$BASE"/*
```

This may become dangerous if `BASE` is empty or unexpected. Defensive scripting checks assumptions first:

```bash
set -u
BASE="/var/tmp/myapp"

case "$BASE" in
  /var/tmp/myapp) ;;
  *) echo "unexpected BASE=$BASE" >&2; exit 1 ;;
esac
```

## 5. Package management

Know the package manager because a manual binary and a package-managed binary have different audit trails.

Debian/Ubuntu:

```bash
apt update
apt list --upgradable
apt-cache policy openssh-server
apt show openssh-server
```

RHEL/Fedora-like systems:

```bash
dnf check-update
rpm -q openssh-server
rpm -qi openssh-server
```

Do not turn `apt update` into an automatic “approve every upgrade” ritual. In production, understand maintenance windows, change control, reboot requirements, kernel updates, and application compatibility.

## 6. Environment and identity snapshot

When troubleshooting, capture a small baseline first:

```bash
id
whoami
hostnamectl
uname -a
cat /etc/os-release
env | sort
ulimit -a
```

For incident work, avoid dumping secrets into logs or tickets. `env` can include tokens, cloud credentials, proxy passwords, or service secrets.

## 7. Mini practical: build a system snapshot

```bash
#!/usr/bin/env bash
set -euo pipefail

printf '\n== identity ==\n'
id
printf '\n== host ==\n'
hostnamectl --static 2>/dev/null || hostname
printf '\n== kernel ==\n'
uname -r
printf '\n== uptime ==\n'
uptime
printf '\n== memory ==\n'
free -h
printf '\n== disks ==\n'
df -hT
printf '\n== listeners ==\n'
ss -lntup
```

Save as `scripts/system_snapshot.sh`, make it executable, and run it on a disposable lab VM.

The point is not the script itself. The point is learning what “normal” looks like on your own machine.
