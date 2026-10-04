# Linux Operations & Security Notes

I’m keeping this repository as a working set of Linux notes for learning, revision, and hands-on practice.

The idea is pretty simple: when I learn a command or a security concept, I want to know **why I would use it, what I should expect to see, and what I would check when the result is not what I expected**.

This is not meant to read like a finished textbook. Some sections are deliberately practical and a little rough around the edges because they are meant to be useful when I am actually working through a problem.

## What is inside

- **Linux fundamentals** — filesystem, shell, users, groups, permissions and processes
- **System administration** — packages, systemd, services, journald, storage and resource checks
- **Linux networking** — interfaces, routes, sockets, DNS, TCP/UDP and packet capture
- **Linux security** — SSH, sudo, capabilities, AppArmor, SELinux awareness, firewalling and auditing
- **Detection and triage** — authentication logs, process investigation, persistence checks and basic evidence handling
- **Practical labs** — small exercises that can be run on a Linux VM, WSL or another authorized test machine
- **Quick reference** — commands I find myself looking up repeatedly
- **Troubleshooting** — common problems and a sensible order for checking them

## How I’m using the notes

I generally try to follow this sequence:

```text
observe → verify → understand → change → verify again
```

For example, before changing an SSH or firewall setting, I first check the current state:

```bash
sudo sshd -t
sudo sshd -T | less

sudo ufw status verbose
sudo nft list ruleset

systemctl status ssh --no-pager
journalctl -u ssh -n 100 --no-pager
```

It is a small habit, but it makes troubleshooting much less stressful.

## A note about the examples

Most of the examples are aimed at Linux systems and many use commands commonly found on Ubuntu/Debian. A few sections also show RHEL/Fedora or SELinux commands where the concept is useful across distributions.

Do not copy a hardening setting blindly into a production machine. Read the command, understand what it changes, and have a way back before testing it.

## Repository layout

```text
docs/
├── 01-linux-foundations.md
├── 02-files-permissions-processes.md
├── 03-shell-text-networking.md
├── 04-systemd-logs-monitoring.md
├── 05-linux-security-hardening.md
├── 06-linux-network-defense.md
├── 07-detection-response.md
├── 08-labs.md
├── 09-cheatsheet.md
└── 10-troubleshooting.md

scripts/
├── harden_ssh_check.sh
├── log_triage.sh
├── system_snapshot.sh
└── test.sh
```

The scripts are intentionally small. I prefer a script that shows exactly what it is checking over a large “do everything” hardening script.

## Safety

The labs are for systems I own or have permission to test. Packet captures, account changes, firewall changes and security testing can affect real systems, so use a disposable lab whenever possible.

## References

- Ubuntu Server Security: https://ubuntu.com/server/docs/how-to/security/
- Ubuntu AppArmor: https://ubuntu.com/server/docs/how-to/security/apparmor/
- OpenSSH manual: https://www.openssh.com/manual.html
- systemd manuals: https://www.freedesktop.org/software/systemd/man/latest/
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks

## Why I keep this public

I find that writing down a troubleshooting process is more useful than keeping a list of commands in private notes. I can come back later, spot something that was wrong or incomplete, and improve it.

That is basically what this repository is: **Linux notes that I can keep improving as I learn.**

MIT License — see `LICENSE`.
