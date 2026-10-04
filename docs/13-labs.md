# 13 — Practical Lab Track

The labs are designed to be run on a disposable Ubuntu VM, WSL environment, container, or local test host. Use systems you own or have explicit authorization to test.

## Lab 1 — Linux baseline snapshot

### Goal
Learn what a “normal” host looks like.

```bash
hostnamectl
uname -a
uptime
free -h
df -hT
ip -br addr
ip route
ss -lntup
systemctl --failed
```

### Deliverable
Save the output and annotate every listening service.

---

## Lab 2 — Permissions puzzle

### Goal
Understand owner/group/other and directory traversal.

```bash
mkdir -p ~/linux-lab/permissions/shared
cd ~/linux-lab/permissions
printf 'secret lab data\n' > shared/data.txt
chmod 750 shared
chmod 640 shared/data.txt
ls -ld shared
ls -l shared/data.txt
```

Experiment with the execute bit on the directory and explain what changes.

---

## Lab 3 — Find a process from a port

Start:

```bash
python3 -m http.server 8088 --bind 127.0.0.1
```

Then:

```bash
ss -lntp | grep ':8088\b'
ps -fp <PID>
readlink -f /proc/<PID>/exe
```

### Interview question
Why can a port be open locally but unreachable from another machine?

---

## Lab 4 — systemd investigation

Pick an existing lab service:

```bash
systemctl status ssh --no-pager
systemctl cat ssh
journalctl -u ssh -b -n 50 --no-pager
```

Explain how the unit file, process, socket, and journal connect.

---

## Lab 5 — SSH configuration validation

Never experiment first on your only remote session.

```bash
sudo sshd -t
sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|pubkeyauthentication'
```

Make one controlled change in a VM, validate, open a second session, then keep or revert it.

---

## Lab 6 — Packet capture on localhost

Terminal 1:

```bash
python3 -m http.server 8088 --bind 127.0.0.1
```

Terminal 2:

```bash
sudo tcpdump -ni lo -w lab.pcap 'tcp port 8088'
curl http://127.0.0.1:8088/
```

Stop capture with `Ctrl+C`. Open the file in Wireshark on your lab machine and identify the TCP handshake and HTTP request.

---

## Lab 7 — AppArmor observation

On an Ubuntu system:

```bash
sudo aa-status
sudo journalctl -k | grep -i apparmor | tail -n 50
```

Pick one profile and explain what resource it restricts.

---

## Lab 8 — Defensive log triage

Use the sample events in `docs/07-detection-response.md`.

Questions:

1. Which IP generated repeated failures?
2. Which account had a successful session?
3. What time did that happen?
4. What command would you use to correlate it with a process or service event?

---

## Lab 9 — Docker least privilege

Build a tiny image that writes to `/data/result.txt`. Run it as root, then as a non-root UID. Fix permissions without switching back to root.

Try:

```bash
docker run --rm --read-only --tmpfs /tmp image-name
```

Record what breaks and why.

---

## Lab 10 — Docker capabilities

Run a harmless image twice:

```bash
docker run --rm --cap-drop ALL alpine:latest sh -c 'id; cat /proc/1/status | grep Cap'
```

Then compare to default capabilities.

The objective is to understand the privilege reduction, not to hunt for capability exploits.

---

## Lab 11 — Kubernetes RBAC proof

Create the `pod-reader` role from `docs/10-kubernetes-security.md`.

Then test:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:app:reader -n app
kubectl auth can-i delete pods --as=system:serviceaccount:app:reader -n app
```

Write down why the answers are different.

---

## Lab 12 — Secure CI review

Take any small GitHub Actions workflow you control and check:

```text
permissions:
third-party action references:
secrets exposed to fork PRs:
OIDC usage:
production environment protection:
artifact provenance:
```

Do not enable production deployment while experimenting.

---

## Lab 13 — Build your own baseline

Create `baseline.md` for your VM containing:

```text
OS/version:
Kernel:
Running services:
Listening ports:
Admin accounts:
Scheduled tasks:
SSH policy:
Firewall policy:
MAC control:
Central logging:
Backup/recovery test date:
```

Review it monthly and compare deltas.

## Graduation test

You are ready to move to the next level when you can explain, without memorizing commands:

- how a TCP connection reaches a process;
- how a user becomes a process identity;
- how permissions and MAC controls interact;
- how systemd starts a service;
- how logs establish a timeline;
- how a container gets isolation;
- why Kubernetes RBAC is about API authorization, not Unix permissions;
- why CI permissions are part of the security boundary;
- why short-lived identity is safer than long-lived deployment secrets.
