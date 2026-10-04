# 08 — DevSecOps Principles: From “Security Gate” to Engineering System

NIST SSDF describes secure development as a set of practices that should be integrated into an organization's SDLC rather than bolted on at the end. OWASP similarly treats DevSecOps as security built into CI/CD automation.
References:
https://csrc.nist.gov/pubs/sp/800/218/final
https://devguide.owasp.org/en/09-operations/01-devsecops/

## 1. The pipeline is a production system

Treat CI/CD as privileged infrastructure. It has access to source code, build artifacts, environment variables, secrets, package registries, and sometimes production deployment credentials.

A useful pipeline shape:

```text
commit
  ↓
format / lint
  ↓
unit tests
  ↓
SAST / code analysis
  ↓
SCA / dependency review
  ↓
secret detection
  ↓
build
  ↓
SBOM
  ↓
container/image scan
  ↓
signed artifact
  ↓
staged deploy
  ↓
security checks
  ↓
production
```

The exact order varies. The principle is to catch the cheapest problems early and reserve expensive runtime checks for later stages.

## 2. Security ownership

A mature team does not create a ticket called “Security to fix.” It records a concrete engineering owner, evidence, and deadline.

Example finding:

```text
Finding: dependency has a critical known vulnerability
Affected: api/package-lock.json
Evidence: scanner report / advisory ID
Exploitability: package is reachable from HTTP request path
Fix: upgrade package to supported version
Owner: backend team
Due: next release window
Validation: dependency scan + regression tests
```

## 3. Threat modeling in 15 minutes

Use four questions:

1. What are we building?
2. What can an attacker touch?
3. What would be valuable if compromised?
4. What control makes the abuse harder or more detectable?

For a simple API:

```text
Internet → CDN/WAF → API → database
                 ↘ logs → SIEM
```

Threats might include stolen sessions, injection, SSRF, dependency compromise, exposed admin endpoints, or excessive database privileges.

## 4. Supply-chain basics

A build depends on more than your source code:

```text
source
  + dependencies
  + package registries
  + build image
  + CI actions/plugins
  + compiler/runtime
  + deployment image
  + external services
```

Reduce trust where possible:

- pin important build inputs;
- verify package integrity;
- generate an SBOM;
- scan dependencies;
- minimize network access during builds;
- separate build and deploy credentials;
- sign or attest artifacts where your platform supports it.

## 5. Secrets are data with an expiration date

Bad:

```yaml
env:
  AWS_SECRET_ACCESS_KEY: "put-it-here"
```

Better design:

```text
CI job
  → identity token
  → cloud identity provider
  → short-lived access token
  → deployment
```

GitHub documents OIDC specifically to avoid long-lived cloud credentials stored as GitHub secrets. Trust conditions should restrict which repositories, branches/tags, environments, or workflows can receive access.
Reference: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect

## 6. SAST, SCA, DAST, IAST: keep the purpose straight

| Control | Main question |
|---|---|
| SAST | Did we write insecure code? |
| SCA | Did we inherit known-risk dependencies? |
| Secret scanning | Did a credential leak into source or history? |
| DAST | Can an externally reachable running app be abused? |
| Container scan | Does the image contain known-risk packages/config? |
| IaC scan | Did infrastructure code create a risky configuration? |
| SBOM | What components are actually inside the artifact? |

The tools can overlap, but the questions are different.

## 7. Risk-based failure policy

Do not make a pipeline fail because a scanner produced any result. Define policy.

Example:

```text
CRITICAL + exploitable + reachable in production → block release
HIGH + reachable in production              → block or require approval
MEDIUM                                      → create tracked remediation
LOW / dev-only                              → monitor / backlog
```

This creates room for engineering judgment while keeping security measurable.

## 8. DevSecOps metrics that are actually useful

Avoid “number of vulnerabilities” as the only KPI.

Better metrics:

- mean time to remediate exploitable critical findings;
- percentage of releases with a generated SBOM;
- percentage of production images scanned before release;
- percentage of CI workflows using least-privilege token permissions;
- percentage of cloud deployments using short-lived federation;
- number of recurring findings caused by the same root defect.

## 9. Practical: security acceptance criteria

For every new service, write a small security contract:

```text
Authentication: OIDC / session / service identity
Authorization: role model documented
Secrets: no credentials in Git
Dependencies: lockfile + automated update process
Container: non-root runtime where possible
Network: inbound ports documented
Logs: auth + security events emitted
Build: tests + SAST + SCA
Artifact: SBOM generated
Deployment: short-lived identity
Rollback: tested
```
