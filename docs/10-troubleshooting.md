# 10 — Linux Troubleshooting Patterns

## “Permission denied”

Do not jump directly to `chmod 777`.

Check:

```bash
namei -l /path/to/file
ls -l /path/to/file
getfacl /path/to/file
id
```

For a MAC-controlled host:

```bash
sudo aa-status
getenforce 2>/dev/null || true
sudo journalctl -k | grep -Ei 'apparmor|avc|denied' | tail -n 100
```

## “Address already in use”

```bash
ss -lntup | grep ':8080\b'
lsof -iTCP:8080 -sTCP:LISTEN 2>/dev/null
```

Then identify whether the existing listener is expected.

## “Connection refused”

Usually means the host is reachable but no process accepted the connection at that address/port (though middleboxes can produce similar behavior).

Check:

```bash
ip route get <destination>
ss -lntp
sudo nft list ruleset
nc -vz <host> <port>
```

## “Connection timed out”

Think in layers:

```text
route → ARP/ND → firewall → security group / ACL → listener → application
```

Use:

```bash
ip route get <destination>
traceroute -n <destination> 2>/dev/null || tracepath <destination>
nc -vz -w 3 <host> <port>
```

## “Service starts then dies”

```bash
systemctl status <service> --no-pager
journalctl -u <service> -b -n 200 --no-pager
systemctl show <service> -p ExecMainStatus,ExecMainCode,Restart,User
```

Then test the application under the same user and working directory as the service rather than running it manually as root.

## “Disk is full”

```bash
df -hT
df -ih
sudo du -xhd1 / | sort -h
sudo journalctl --disk-usage
```

Different causes require different fixes. Deleting random logs is not a root-cause analysis.

## “Memory is full”

```bash
free -h
ps aux --sort=-%mem | head -n 20
cat /proc/meminfo | head -n 30
```

On modern Linux, “used memory” is not the same as “memory pressure.” Look at available memory, swap, and workload behavior.

## “DNS works on one machine but not another”

Compare:

```bash
cat /etc/resolv.conf
resolvectl status 2>/dev/null
getent hosts example.com
dig example.com
```

Also check split DNS, VPN configuration, search domains, and local resolver caches.

## “SSH stopped working after a configuration change”

From the server console/out-of-band channel:

```bash
sudo sshd -t
sudo systemctl status ssh --no-pager
sudo journalctl -u ssh -b --no-pager
```

Restore the last known-good configuration only after preserving the failing version for analysis.
