# 11 — GitHub Actions Security

GitHub treats Actions workflows as privileged automation. The dangerous combination is a workflow that can modify code/deployments and also has access to secrets.

GitHub's current guidance emphasizes explicitly declaring least-privilege `GITHUB_TOKEN` permissions, pinning third-party actions to full-length commit SHAs, and restricting which actions may execute.
References:
https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
https://docs.github.com/en/enterprise-cloud%40latest/code-security/tutorials/secure-your-organization/protect-against-threats

## 1. Start every workflow with explicit permissions

```yaml
permissions:
  contents: read
```

Then grant additional permission at the job level only when needed.

For OIDC:

```yaml
permissions:
  id-token: write
  contents: read
```

`id-token: write` allows requesting an OIDC token; it does not itself grant cloud-resource write access. The cloud trust policy decides which identity gets which external privileges.
Reference: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/oidc-in-cloud-providers

## 2. Pin actions

GitHub's security-hardening guidance states that a full-length commit SHA is the immutable way to reference an action release. Tags are convenient but mutable.
Reference: https://docs.github.com/github-ae%40latest/actions/security-guides/security-hardening-for-github-actions

Example:

```yaml
- uses: actions/checkout@<FULL_COMMIT_SHA>
```

Do not invent the SHA. Resolve it from the action repository, verify that it belongs to the intended release, and record why the version was selected.

## 3. Pull requests from forks need extra care

Treat workflow code as code that may be influenced by an attacker.

Dangerous patterns include:

```yaml
pull_request_target:
  # then checking out attacker-controlled code and executing it
```

A safer mindset is:

```text
untrusted PR code → low privilege → no production secrets
trusted branch    → stronger permissions after review
```

Use separate workflows/jobs when trust levels differ.

## 4. Do not print secrets

Bad:

```bash
echo "$TOKEN"
set -x
```

Avoid commands that dump full environments or HTTP headers containing credentials.

## 5. OIDC beats long-lived cloud keys

A strong deployment pattern is:

```text
GitHub workflow
   ↓ OIDC token
cloud identity provider
   ↓ short-lived credentials
deployment API
```

GitHub requires a trust relationship and recommends claims/conditions so an unrelated repository cannot request access to your resources.
Reference: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/oidc-in-cloud-providers

## 6. Environment protection

For production deployments, consider:

- protected environments;
- required approvals;
- restricted deployment branches/tags;
- separate production identity;
- explicit OIDC subject conditions;
- audit logs.

Do not use a single broad cloud credential for every environment.

## 7. Dependency and code security

A mature repository turns on multiple layers:

```text
Dependabot / dependency updates
+ secret scanning
+ push protection
+ code scanning
+ dependency review
+ CI tests
```

The tools change over time; the underlying principle is continuous detection before release.

## 8. Workflow example: intentionally minimal

```yaml
name: secure-ci

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@<PINNED_SHA>

      - name: Show versions
        run: |
          git --version
          python3 --version

      - name: Run tests
        run: |
          ./scripts/test.sh
```

The placeholder is intentional. Copying a random SHA into your workflow without checking the release defeats the point of immutable pinning.

## 9. Secure workflow review checklist

```text
[ ] permissions explicitly declared
[ ] third-party actions pinned
[ ] fork PR trust boundary understood
[ ] secrets unavailable to untrusted jobs
[ ] production environment protected
[ ] cloud credentials short-lived where possible
[ ] OIDC trust conditions restrictive
[ ] generated artifacts treated as untrusted input
[ ] logs do not expose secrets
[ ] self-hosted runners isolated appropriately
```
