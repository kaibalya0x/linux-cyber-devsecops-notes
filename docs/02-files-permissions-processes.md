# 02 — Permissions, Privilege, Processes, and Users

## 1. Linux permission model

Start with the classic view:

```bash
ls -l file.txt
# -rw-r----- 1 alice analysts 1200 Oct  4 20:00 file.txt
```

Read the columns as:

```
type | owner permissions | group permissions | other permissions
```

The first character can describe a regular file (`-`), directory (`d`), symbolic link (`l`), socket (`s`), and more.

### Numeric mode

```bash
chmod 640 report.txt
chmod 750 deploy.sh
chmod 600 secret.key
```

Numeric mode is useful, but reasoning is better than memorization:

- 4 = read
- 2 = write
- 1 = execute

The execute bit means different things on files and directories. On a directory, execute means you may traverse/search it. A directory with `r` but no `x` is a classic “I can list names but cannot access entries” puzzle.

## 2. `sudo` is an authorization boundary

Do not think of `sudo` as “run as root.” Think of it as “request a command under an authorization policy.”

Inspect the effective policy:

```bash
sudo -l
```

Check which identity a command sees:

```bash
id
sudo id
sudo -u www-data id
```

A practical security rule: grant the narrowest command and arguments that solve the task. Giving a user unrestricted `sudo` is easy; taking it back safely is harder.

## 3. SUID and SGID

Find set-user-ID binaries on a lab box:

```bash
sudo find / -xdev -type f -perm -4000 -ls 2>/dev/null
```

Set-group-ID search:

```bash
sudo find / -xdev -type f -perm -2000 -ls 2>/dev/null
```

Do not treat every SUID file as malicious. Many legitimate system binaries need elevated privileges. The investigation question is: “Is this expected for this host, package, version, and role?”

## 4. Sticky bit

The sticky bit is especially useful to understand in shared directories:

```bash
ls -ld /tmp
```

A directory such as `/tmp` commonly ends in `t` in its mode, helping restrict who can remove another user's file there.

## 5. ACLs

Traditional mode bits are not the whole story.

```bash
getfacl file.txt
setfacl -m u:bob:r-- file.txt
getfacl file.txt
```

Remove the ACL entry again:

```bash
setfacl -x u:bob file.txt
```

When access looks impossible to explain from `ls -l` alone, check ACLs before inventing a complicated theory.

## 6. Processes: investigate the process, then its parent

Useful commands:

```bash
ps aux --sort=-%cpu | head
ps -eo pid,ppid,user,group,stat,etime,cmd --forest
pgrep -a ssh
pstree -ap
```

For one process:

```bash
PID=$(pgrep -n sshd)
cat "/proc/$PID/status"
readlink -f "/proc/$PID/exe"
tr '\0' ' ' < "/proc/$PID/cmdline"; echo
ls -l "/proc/$PID/fd" | head
```

A useful investigation chain is:

```
PID → PPID → executable → command line → user → cwd → open files → sockets → logs
```

## 7. Process capabilities

Modern Linux privilege is not just UID 0. Capabilities split privileged operations into smaller units.

```bash
getcap -r /usr/bin /usr/sbin 2>/dev/null
capsh --print 2>/dev/null | head -n 40
```

Capabilities matter because Linux can delegate specific privileged operations without giving a process full UID 0 privileges. When investigating a process, inspect its effective capabilities before assuming that a non-root UID means low privilege.

## 8. Process practical: explain an unexpected listener

Suppose port 8080 is listening.

Start with:

```bash
ss -lntp | grep ':8080\b'
```

Then identify the process:

```bash
ps -fp <PID>
readlink -f /proc/<PID>/exe
tr '\0' ' ' < /proc/<PID>/cmdline; echo
ls -l /proc/<PID>/cwd
```

Then ask the service manager what launched it:

```bash
systemctl status <service> --no-pager
systemctl cat <service>
```

If it is not a systemd service, investigate its parent:

```bash
ps -o pid,ppid,user,cmd -p <PID>
ps -fp <PPID>
```

## 9. User account review

```bash
getent passwd
getent group
sudo awk -F: '$3==0 {print}' /etc/passwd
sudo passwd -S root 2>/dev/null || true
last -a | head -n 20
lastlog | head -n 20
```

A UID of 0 is the critical clue: every UID 0 account is effectively root. Do not rely solely on the literal username `root`.

## 10. Practical: build a least-privilege service account

For a generic application service account, the design goal is:

- no interactive login unless necessary;
- no membership in administrative groups unless necessary;
- ownership limited to the application's working directories;
- a dedicated systemd unit with a restricted filesystem view where practical;
- secrets delivered through a controlled mechanism rather than world-readable files.

Example skeleton:

```bash
sudo useradd --system --home /nonexistent --shell /usr/sbin/nologin myapp
sudo install -d -o myapp -g myapp -m 0750 /opt/myapp
```

Verify:

```bash
getent passwd myapp
id myapp
ls -ld /opt/myapp
```

Do not blindly copy this into production. A real service may require a writable cache, socket, device, or data directory. Least privilege is an engineering exercise, not a magic permission number.
