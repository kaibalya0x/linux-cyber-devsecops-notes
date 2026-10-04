# 09 — Linux Security & Operations Quick Reference

## Identity

```bash
id
whoami
who
last -a | head
```

## Host

```bash
hostnamectl
cat /etc/os-release
uname -r
uptime
```

## Files

```bash
ls -lah
stat file
file file
find /path -type f -mtime -1
sha256sum file
```

## Permissions

```bash
namei -l /path/to/file
getfacl file
getcap -r /usr/bin /usr/sbin 2>/dev/null
sudo -l
```

## Processes

```bash
ps aux
ps -eo pid,ppid,user,stat,etime,cmd --forest
pstree -ap
lsof -p <PID>
```

## Network

```bash
ip -br addr
ip route
ip route get 1.1.1.1
ss -lntup
ss -tpn state established
getent hosts example.com
dig example.com
curl -v https://example.com
```

## Logs

```bash
journalctl -b
journalctl -p warning..alert
journalctl -u ssh --since '1 hour ago'
journalctl -k
```

## Services

```bash
systemctl status <service>
systemctl cat <service>
systemctl is-enabled <service>
systemctl --failed
```

## Firewall

```bash
sudo ufw status verbose
sudo nft list ruleset
```

## SSH

```bash
ssh -vvv user@host
sudo sshd -t
sudo sshd -T
```

## Security habits

Before changing a setting, capture the current state. Keep a rollback path. Do not use `chmod 777` as a troubleshooting shortcut.

Never store private keys, passwords, API tokens, or real customer data in an educational repository.
