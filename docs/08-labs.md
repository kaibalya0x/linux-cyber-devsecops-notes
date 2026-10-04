# 08 — Practical Linux Lab Track

The labs are designed to be run on a disposable Ubuntu VM, WSL environment, or local Linux test host. Use systems you own or have explicit authorization to test.

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

## Lab 9 — Linux capabilities

Inspect the capabilities available to your current shell and to a known system process:

```bash
capsh --print 2>/dev/null || true
grep '^Cap' /proc/1/status
getcap -r /usr/bin /usr/sbin 2>/dev/null | head -n 50
```

Write down why capabilities exist and why UID 0 is not the only privilege signal.

---

## Lab 10 — Linux network namespace

Create a disposable network namespace:

```bash
sudo ip netns add labns
sudo ip netns exec labns ip link
sudo ip netns exec labns ip route
sudo ip netns exec labns ss -lntup
sudo ip netns del labns
```

The objective is to understand how Linux can isolate network interfaces, routes, and sockets from the host namespace.

---

## Lab 11 — Firewall observation

Check the active firewall tooling before changing anything:

```bash
sudo ufw status verbose
sudo nft list ruleset
```

Document which rules affect inbound and outbound traffic. Do not flush or replace production rules during practice.

---

## Lab 12 — Build your own Linux baseline

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
- how Linux namespaces isolate resources;
- how firewall rules affect packet flow;
- how to preserve evidence while troubleshooting a suspicious host;
- how to compare a current host state against a known baseline.
