# Linux → Cybersecurity → DevSecOps Field Notes

> A practical, command-first notebook for learning Linux as an operator, defender, and DevSecOps engineer.

This repository is deliberately organized like working notes rather than a textbook. Each topic answers four questions:

1. **What is happening?**
2. **What command shows me the truth?**
3. **What can go wrong?**
4. **How would I investigate it at 2 AM?**

The material is original synthesis built from Linux/Ubuntu, OpenSSH, GitHub, Docker, Kubernetes, OWASP, NIST and CIS guidance. It is not a copy of any one vendor's documentation.

## What this covers

| Layer | Focus |
|---|---|
| Linux foundations | shell, filesystem, users, permissions, processes, packages |
| Operations | systemd, journald, storage, networking, troubleshooting |
| Security | SSH, sudo, MAC, firewalling, auditing, hardening, incident triage |
| Detection | logs, process/network triage, IOC thinking, evidence handling |
| Containers | Docker image/build/runtime security, secrets, least privilege |
| Kubernetes | RBAC, workloads, secrets, admission, network boundaries |
| DevSecOps | secure Git, CI/CD, SAST, SCA, secrets, SBOM, image scanning, OIDC |
| Practice | repeatable local labs and defensive exercises |

## Suggested path

**Week 1:** `docs/01-linux-foundations.md` → `docs/02-files-permissions-processes.md`
**Week 2:** `docs/03-shell-text-networking.md` → `docs/04-systemd-logs-monitoring.md`
**Week 3:** `docs/05-linux-security-hardening.md` → `docs/06-linux-network-defense.md`
**Week 4:** `docs/07-detection-response.md`
**Week 5:** `docs/08-devsecops-principles.md` → `docs/09-docker-security.md`
**Week 6:** `docs/10-kubernetes-security.md` → `docs/11-github-actions-security.md` → `docs/12-secure-ci-pipeline.md`

Use `docs/13-labs.md` when you want to turn reading into muscle memory.

## Safety boundary

Everything here is intended for systems you own or are explicitly authorized to test. The labs focus on administration, defensive testing, detection, hardening, and safe emulation of failures. Do not run scanning, exploitation, password testing, or configuration changes against systems without authorization.

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
- OpenSSH: https://www.openssh.com/manual.html
- systemd: https://www.freedesktop.org/software/systemd/man/latest/
- NIST SSDF SP 800-218: https://csrc.nist.gov/pubs/sp/800/218/final
- OWASP DevSecOps: https://devguide.owasp.org/en/09-operations/01-devsecops/
- GitHub Actions security: https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
- GitHub OIDC: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- Docker build secrets: https://docs.docker.com/build/building/secrets/
- Kubernetes security checklist: https://kubernetes.io/docs/concepts/security/security-checklist/
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks

## License

MIT — see `LICENSE`.
