# 07 — Linux Detection and Incident Triage

## 1. The defender's first job is to build a timeline

When something feels wrong, do not start with “find the hacker.” Start with:

```text
What changed?
When did it change?
Which account did it involve?
Which process made the change?
What network activity followed?
What evidence can still prove the sequence?
```

A simple timeline can be more useful than a giant pile of logs.

## 2. First-response snapshot

Run read-only commands first:

```bash
date -Is
hostnamectl
id
uptime
who
w
last -a | head -n 30
ps -eo user,pid,ppid,lstart,cmd --sort=lstart | tail -n 40
ss -tpn
ss -lntup
systemctl --failed
journalctl -b -p warning..alert --no-pager
```

Record outputs in a case directory rather than editing the original host.

Example:

```bash
CASE="case-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$CASE"
date -Is > "$CASE/time.txt"
id > "$CASE/id.txt"
ss -tpn > "$CASE/sockets.txt"
ps -eo user,pid,ppid,lstart,cmd > "$CASE/processes.txt"
```

## 3. Authentication triage

Ubuntu/Debian may record SSH authentication in `/var/log/auth.log`; journald systems can also be queried through the service journal.

```bash
sudo journalctl -u ssh --since '24 hours ago' --no-pager
sudo grep -Ei 'failed|invalid|accepted|session opened|session closed' /var/log/auth.log 2>/dev/null | tail -n 200
```

Do not assume the exact filename, message text, or service name is identical on every distribution.

Useful questions:

- Were there repeated failures from one address?
- Was a successful login preceded by failures?
- Did the successful session use an expected account and source?
- What happened immediately after login?

## 4. Process triage

For an unfamiliar process:

```bash
PID=1234
ps -fp "$PID"
readlink -f "/proc/$PID/exe"
tr '\0' ' ' < "/proc/$PID/cmdline"; echo
readlink -f "/proc/$PID/cwd"
ls -l "/proc/$PID/fd" | head -n 30
sudo cat "/proc/$PID/status" | egrep 'Name|State|Uid|Gid|PPid|Cap'
```

Then:

```bash
pstree -aps "$PID"
sudo ss -tpn | grep "pid=$PID,"
```

The parent-child relationship often reveals whether a process came from a service manager, a shell, a kernel worker, or a user session.

## 5. Persistence review

Look at common persistence locations without modifying anything:

```bash
systemctl list-unit-files --state=enabled
systemctl --user list-unit-files --state=enabled 2>/dev/null
crontab -l 2>/dev/null
sudo crontab -l 2>/dev/null
sudo ls -la /etc/cron.*
find ~/.config/systemd/user -type f -maxdepth 2 2>/dev/null
```

Also review shell startup files when relevant:

```bash
ls -la ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null
```

Again, presence does not equal compromise. Compare against baseline and expected application behavior.

## 6. File change triage

Recent modifications can narrow an investigation:

```bash
sudo find /etc /usr/local /opt -xdev -type f -mmin -240 -ls 2>/dev/null | head -n 200
```

For a known suspicious file:

```bash
stat suspicious.file
file suspicious.file
sha256sum suspicious.file
```

Compare the hash with a trusted package or known-good deployment artifact where possible.

## 7. Detection logic examples

A useful detection is not merely a string match. It should combine context.

### Example: suspicious new listener

```text
new listening port
      +
process is not in approved inventory
      +
process binary path is unexpected
      +
process started recently
      =
high-value investigation
```

### Example: unusual privileged command

```text
sudo event
 + user rarely uses sudo
 + command touches auth/config files
 + event occurs outside expected maintenance window
 = investigate
```

## 8. Do not destroy evidence while “cleaning”

Avoid immediately:

```bash
kill -9 <PID>
rm suspicious.file
apt purge package
reboot
```

Those actions may be correct later, but they can destroy information that explains what happened.

A safer sequence is usually:

```text
observe → preserve → contain → eradicate → recover → learn
```

The exact order changes with the incident and safety requirements.

## 9. Safe log-analysis practical

Create a small sample file:

```text
Oct 04 20:10:01 app sshd[100]: Failed password for invalid user test from 192.0.2.10 port 50000 ssh2
Oct 04 20:10:05 app sshd[101]: Failed password for invalid user admin from 192.0.2.10 port 50004 ssh2
Oct 04 20:11:22 app sshd[102]: Accepted publickey for ops from 198.51.100.20 port 50100 ssh2
Oct 04 20:11:22 app sshd[102]: pam_unix(sshd:session): session opened for user ops
```

Then answer with shell tools:

```bash
grep 'Failed password' sample-auth.log \
 | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' \
 | sort | uniq -c | sort -nr
```

The exercise is to turn raw text into a question: “Which source addresses generated repeated failures?”

## 10. Evidence notes template

```text
Incident ID:
Host:
Analyst:
First observed:
Last observed:
Business function:
Suspected change:
Affected account(s):
Affected process(es):
Network indicators:
Evidence collected:
Containment action:
Recovery action:
Open questions:
```


## The part that is easy to get wrong

During an investigation it is tempting to kill the strange process, delete the suspicious file and reboot. Those actions might eventually be necessary, but doing them first can remove the evidence that explains what happened.

For learning purposes, I try to practice the quieter workflow:

```text
observe → record → preserve → investigate → contain
```

It also makes the later cleanup decision much easier because there is a reason behind it.
