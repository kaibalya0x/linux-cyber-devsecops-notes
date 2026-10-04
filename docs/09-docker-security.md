# 09 — Docker and Container Security

## 1. A container is not a tiny VM

A container shares the host kernel. Isolation is built from namespaces, cgroups, Linux capabilities, seccomp, MAC controls, filesystem boundaries, and the runtime.

That is why “the process runs as root inside the container” still deserves attention: container root is not automatically equivalent to host root, but reducing privilege is still an important defense-in-depth measure.

## 2. Dockerfile baseline

Prefer:

```dockerfile
FROM python:3.13-slim

RUN useradd --create-home --uid 10001 appuser
WORKDIR /app

COPY --chown=appuser:appuser requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser . .
USER 10001

EXPOSE 8080
CMD ["python", "app.py"]
```

This is only a teaching example. Pinning a base image by digest can improve reproducibility but requires a maintenance process when vulnerabilities are fixed.

## 3. Build secrets correctly

Do not use `ARG` or normal environment variables to pass build secrets. Docker documents secret mounts and SSH mounts specifically because ordinary build arguments/environment variables can persist in the resulting image or build metadata.
Reference: https://docs.docker.com/build/building/secrets/

Example:

```bash
docker build --secret id=npmrc,src="$HOME/.npmrc" -t lab-app .
```

Dockerfile:

```dockerfile
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm ci
```

The application should not need the build secret at runtime.

## 4. Inspect an image before trusting it

```bash
docker image inspect myapp:dev
docker history myapp:dev
```

Check:

- base image provenance;
- installed packages;
- unexpected shells/tools;
- user identity;
- exposed ports;
- environment variables;
- working directory;
- entrypoint.

## 5. Runtime privilege reduction

Useful flags to learn in a lab:

```bash
docker run --rm \
  --user 10001:10001 \
  --cap-drop ALL \
  --read-only \
  --tmpfs /tmp \
  myapp:dev
```

Some applications will fail. That failure is useful: it reveals what the container actually depends on.

Add capabilities only when you can explain why:

```bash
--cap-add NET_BIND_SERVICE
```

Avoid the shortcut:

```bash
--privileged
```

unless you are intentionally building a privileged lab workload and understand the consequences.

## 6. Filesystem controls

A read-only root filesystem changes the attacker's options after compromise:

```bash
docker run --read-only --tmpfs /tmp myapp:dev
```

The application may need a writable data directory. Mount only that path rather than making the whole container writable.

## 7. Network controls

Avoid putting every container on a flat network. For a typical three-tier design:

```text
frontend → api → database
```

The frontend should not automatically have database network access.

Inspect:

```bash
docker network ls
docker network inspect <network>
```

## 8. Image scanning

A scanner such as Trivy can scan an image for known vulnerabilities. Treat the scanner as one signal; validate reachability and runtime exposure before assigning severity.

Example:

```bash
trivy image --scanners vuln,misconfig myapp:dev
```

Do not upload proprietary images to a third-party scanning service unless your organization's policy allows it.

## 9. Docker practical: intentionally break a privilege assumption

Build an image whose application writes to `/app/runtime.log`. First run as root. Then change to:

```dockerfile
USER 10001
```

Run again.

Instead of simply switching back to root, fix the directory ownership:

```dockerfile
RUN install -d -o 10001 -g 10001 /app/data
```

The lesson is important: security failures often show you where an application is coupled to excessive privilege.

## 10. Container checklist

```text
[ ] Minimal base image appropriate for the application
[ ] Base image update process exists
[ ] Dependencies are locked/reviewed
[ ] Image scanned before release
[ ] Runtime does not need root
[ ] Unneeded capabilities removed
[ ] Root filesystem read-only where practical
[ ] Writable paths explicit
[ ] Secrets not baked into image layers
[ ] Network access is intentional
[ ] Health checks are present
[ ] SBOM is generated for release artifacts
```
