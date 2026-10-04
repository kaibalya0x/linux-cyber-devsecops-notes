# Research and Source Notes

**Research snapshot:** 2026-10-04  
**Purpose:** keep the handbook grounded in primary Linux documentation and practical security guidance.

This repository is an original synthesis. It intentionally uses concepts from established Linux and security documentation, then rewrites them into a command-first learning path with labs and troubleshooting patterns. It does **not** claim that every idea here is globally unique; no responsible author can prove that for the entire internet.

## Primary sources used

### Linux host security

- Ubuntu Server Security: https://ubuntu.com/server/docs/how-to/security/
- Ubuntu Security Introduction: https://ubuntu.com/server/docs/explanation/intro-to/security/
- Ubuntu Security Suggestions: https://ubuntu.com/server/docs/explanation/security/security_suggestions/
- Ubuntu AppArmor: https://ubuntu.com/server/docs/how-to/security/apparmor/
- OpenSSH manual: https://www.openssh.com/manual.html
- systemd manual index: https://www.freedesktop.org/software/systemd/man/latest/

### Linux security guidance

- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks
- CIS Linux Benchmarks: https://www.cisecurity.org/benchmark/distribution_independent_linux
- Linux Audit documentation: https://linux-audit.com/

## How to use sources

Prefer primary documentation for configuration syntax and current platform behavior. Use security benchmarks for control intent and verification ideas. Use community material for troubleshooting patterns, not as the sole authority for security decisions.

## Version drift warning

Linux distributions, kernels, OpenSSH, systemd, firewall tooling, and security profiles change independently. A command that worked yesterday may still exist but have a different recommended workflow today. The repository therefore teaches the investigation method as well as the command itself.
