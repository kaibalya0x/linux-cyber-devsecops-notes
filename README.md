# Linux Operations & Security Field Notes

> A practical, command-first notebook for learning Linux as an operator, troubleshooter, and defender.

This repository is organized like working notes rather than a textbook. Each topic is built around four questions:

1. **What is happening?**
2. **What command shows me the current state?**
3. **What can go wrong?**
4. **How would I investigate it at 2 AM?**

The material is an original synthesis of Linux administration, networking, system security, logging, and incident-triage knowledge. It is written as practical notes rather than copied vendor documentation.

## What this covers

| Area | Focus |
|---|---|
| Linux foundations | shell, filesystem, users, permissions, processes, packages |
| Operations | systemd, journald, storage, networking, troubleshooting |
| Security | SSH, sudo, capabilities, MAC controls, firewalling, auditing, hardening |
| Networking | interfaces, routes, sockets, DNS, packet inspection, host firewalling |
| Detection | authentication logs, process/network triage, IOC thinking, evidence handling |
| Practical labs | repeatable Linux exercises on a VM, WSL environment, or test host |
| Reference material | concise command examples, investigation patterns, and troubleshooting notes |

## Suggested path

**Start here:** `docs/01-linux-foundations.md` → `docs/02-files-permissions-processes.md`

**Build operator skills:** `docs/03-shell-text-networking.md` → `docs/04-systemd-logs-monitoring.md`

**Build security skills:** `docs/05-linux-security-hardening.md` → `docs/06-linux-network-defense.md`

**Practice investigation:** `docs/07-detection-response.md`

**Then practice:** `docs/08-labs.md` → `docs/09-cheatsheet.md` → `docs/10-troubleshooting.md`

## Safety boundary

Everything here is intended for systems you own or are explicitly authorized to test. The labs focus on administration, defensive testing, detection, hardening, and safe emulation of failures. Do not run scanning, password testing, packet capture, or configuration changes against systems without authorization.

## A useful habit

When a command changes a system, first learn the read-only command that explains the current state. For example:

```bash
# before changing SSH settings
sudo sshd -t
sudo sshd -T | less

# before changing a firewall
sudo ufw status verbose
sudo nft list ruleset

# before restarting a service
systemctl status ssh --no-pager
journalctl -u ssh -n 100 --no-pager
```

This one habit prevents a surprising number of outages.

## Primary references

- Ubuntu Server Security: https://ubuntu.com/server/docs/how-to/security/
- Ubuntu AppArmor: https://ubuntu.com/server/docs/how-to/security/apparmor/
- OpenSSH manual: https://www.openssh.com/manual.html
- systemd manuals: https://www.freedesktop.org/software/systemd/man/latest/
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks

## License

MIT — see `LICENSE`.
