# 12 — Building a Secure CI Pipeline You Can Actually Maintain

## 1. Reference architecture

```text
Developer
   |
   v
Git repository
   |
   +--> lint / unit tests
   |
   +--> SAST
   |
   +--> SCA + dependency policy
   |
   +--> secret scan
   |
   +--> build artifact
   |
   +--> SBOM
   |
   +--> image scan
   |
   +--> sign / attest
   |
   +--> staging
   |
   +--> smoke + security tests
   |
   +--> protected production deployment via OIDC
```

## 2. Example local CI stages

Even without GitHub Actions, reproduce the same logic locally:

```bash
./scripts/check_format.sh
./scripts/run_tests.sh
./scripts/check_secrets.sh
./scripts/build.sh
```

CI should automate a process that developers can understand locally.

## 3. SBOM thinking

An SBOM answers: “What components are in this artifact?”

For containers, tools such as Syft can generate SBOMs and Grype or Trivy can help find known issues. Tool choice is less important than keeping the artifact-to-SBOM relationship traceable.

A practical metadata record:

```text
artifact digest
build ID
source commit
builder image
SBOM location
scanner version
scan timestamp
release decision
```

## 4. Reproducibility

For a given commit, you want to know which inputs influenced the build.

Record:

- source commit;
- dependency lockfile hash;
- base image digest;
- builder version;
- build script version;
- artifact digest.

Do not assume “same tag” means “same bits.” Tags can move.

## 5. Release gates

One practical policy table:

| Signal | Example action |
|---|---|
| Unit test failure | Block |
| Secret found | Block + revoke/rotate |
| Critical reachable CVE | Block |
| Critical non-reachable CVE | Track + review |
| Medium dependency issue | Track |
| SBOM missing | Block release |
| Signature missing for production | Block release |
| Deployment identity not compliant | Block |

The important thing is that every gate has an owner and a reason.

## 6. Reusable shell guardrails

A small script can fail safely:

```bash
#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing command: $1" >&2
    exit 1
  }
}

for cmd in git sha256sum; do
  require_cmd "$cmd"
done

if git diff --exit-code --quiet; then
  echo "working tree clean"
else
  echo "working tree has uncommitted changes" >&2
  exit 1
fi
```

This is intentionally boring. CI security improves when guardrails are understandable enough to maintain.

## 7. Separate build from deployment

Build jobs should not automatically receive production secrets.

```text
build runner
  ├─ source
  ├─ tests
  └─ artifact

promotion job
  ├─ approved artifact digest
  ├─ protected environment
  └─ short-lived production identity
```

This creates a useful blast-radius boundary.

## 8. Supply-chain review exercise

Pick one dependency from a real project and document:

```text
Why do we use it?
Who maintains it?
How is it versioned?
How is integrity verified?
How fast do security updates reach us?
Can we replace it?
What breaks if it disappears?
```

Repeat this for your CI actions and base images. This is where DevSecOps becomes engineering rather than tool collecting.

## 9. Production release proof

A strong deployment record should let you answer later:

```text
What source commit is running?
What exact image digest is running?
Which scanner versions ran?
Which policy decision allowed release?
Which identity deployed it?
Which environment approved it?
Can we reproduce or roll back it?
```

That is the operational meaning of software supply-chain visibility.
