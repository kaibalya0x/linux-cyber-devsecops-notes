# Research and Source Notes

**Research snapshot:** 2026-10-04
**Purpose:** keep the handbook grounded in primary documentation and current security guidance.

This repository is an original synthesis. It intentionally uses concepts from established standards and vendor documentation, then rewrites them into a command-first learning path with labs and troubleshooting patterns. It does **not** claim that every idea here is globally unique; no responsible author can prove that for the entire internet.

## Primary sources used

### Linux host security

- Ubuntu Server Security: https://ubuntu.com/server/docs/how-to/security/
- Ubuntu Security Introduction: https://ubuntu.com/server/docs/explanation/intro-to/security/
- Ubuntu Security Suggestions: https://ubuntu.com/server/docs/explanation/security/security_suggestions/
- Ubuntu AppArmor: https://ubuntu.com/server/docs/how-to/security/apparmor/
- OpenSSH manual: https://www.openssh.com/manual.html
- systemd manual index: https://www.freedesktop.org/software/systemd/man/latest/

### Security frameworks

- NIST SP 800-218 Secure Software Development Framework (SSDF): https://csrc.nist.gov/pubs/sp/800/218/final
- OWASP DevSecOps Guideline: https://devguide.owasp.org/en/09-operations/01-devsecops/
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks

### GitHub Actions

- GitHub Actions security hardening: https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
- GitHub security hardening for deployments / OIDC: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- GitHub OIDC in cloud providers: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/oidc-in-cloud-providers
- GitHub threat protection and workflow hardening: https://docs.github.com/en/enterprise-cloud%40latest/code-security/tutorials/secure-your-organization/protect-against-threats
- GitHub Actions release page for current checkout releases: https://github.com/actions/checkout/releases
- GitHub CodeQL Action releases: https://github.com/github/codeql-action/releases

At this snapshot, the checkout release page shows **v7.0.1** as current, with commit `3d3c42e5aac5ba805825da76410c181273ba90b1`. The CodeQL Action release page shows **v4.38.1** as the current v4 release in the source set used for the workflow, with commit `1c5b675653bb5c22dbe9b12b556ec555138e09fd`. These pins should be reviewed and deliberately updated as upstream releases change.

### Containers

- Docker build secrets: https://docs.docker.com/build/building/secrets/
- Docker build best practices: https://docs.docker.com/build/building/best-practices/

### Kubernetes

- Kubernetes security checklist: https://kubernetes.io/docs/concepts/security/security-checklist/
- Kubernetes application security checklist: https://kubernetes.io/docs/concepts/security/application-security-checklist/

## How to use sources

Prefer primary documentation for configuration syntax and current platform behavior. Use standards such as NIST/OWASP/CIS for control intent. Use community material for troubleshooting patterns, not as the sole authority for security decisions.

## Version drift warning

Linux distributions, OpenSSH, Docker, Kubernetes, GitHub Actions, scanners and CI runners change independently. A command that worked yesterday may still exist but have a different recommended workflow today. The repository therefore teaches the investigation method as well as the command itself.
