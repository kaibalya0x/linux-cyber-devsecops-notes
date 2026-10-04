# 03 — Shell, Text Processing, and Network Troubleshooting

## 1. Pipes are a security analyst's workbench

A good pipeline keeps each stage simple:

```bash
journalctl -u ssh --no-pager | grep -Ei 'failed|invalid|authentication'
```

Use `awk` when the data is column-oriented:

```bash
ps -eo user,pid,%cpu,%mem,cmd --sort=-%cpu | head -n 15
```

Use `cut` for simple delimiters:

```bash
cut -d: -f1,3 /etc/passwd
```

Use `sort` + `uniq -c` for frequency:

```bash
grep 'Failed password' /var/log/auth.log 2>/dev/null \
  | awk '{print $(NF-3)}' \
  | sort | uniq -c | sort -nr | head
```

Log formats differ by distro and version, so treat column positions as an example, not a universal truth.

## 2. Search with intent

```bash
grep -Rni --exclude-dir=.git 'PermitRootLogin' /etc/ssh 2>/dev/null
find /var/log -type f -mtime -1 -print
```

For JSON logs, use `jq` instead of trying to parse nested data with `grep`:

```bash
jq '.level, .message' app.json
jq 'select(.status >= 400) | {ts, status, path}' app.json
```

## 3. DNS: prove each layer

```bash
getent hosts example.com
resolvectl status 2>/dev/null
resolvectl query example.com 2>/dev/null
```

Compare resolver behavior to direct DNS tools where available:

```bash
dig example.com A
dig example.com AAAA
```

Common trap: a successful DNS lookup proves name resolution only. It does not prove that TCP, TLS, HTTP, or application authentication will work.

## 4. TCP connectivity

```bash
ip addr
ip route
ss -s
ss -lntup
```

Test a specific port:

```bash
nc -vz 10.10.10.20 443
```

Then compare with:

```bash
curl -vk https://10.10.10.20/
```

`nc` answers a transport-level question. `curl` can take you further into TLS and HTTP.

## 5. HTTP investigation

```bash
curl -I https://example.com
curl -v https://example.com/health
curl --resolve app.example.com:443:10.10.10.20 https://app.example.com/health -v
```

The last command is especially useful when the server uses SNI/virtual hosts and you need to hit a particular IP without changing DNS.

## 6. Packet capture: start narrow

For an authorized lab interface:

```bash
sudo tcpdump -ni any 'tcp port 443'
```

Narrow by host and port:

```bash
sudo tcpdump -ni any 'host 10.10.10.20 and tcp port 443'
```

Capture to a file for later analysis:

```bash
sudo tcpdump -ni any -w lab-http.pcap 'host 10.10.10.20 and tcp port 443'
```

Avoid collecting traffic you do not need. Packet captures can contain credentials, cookies, personal data, and other sensitive information.

## 7. Routing practical

Ask the kernel which route it would use:

```bash
ip route get 1.1.1.1
```

If it chooses an unexpected interface or gateway, fix the route rather than guessing about the firewall.

## 8. The five-minute network triage sequence

```
1. Is the interface up?        ip link
2. Does it have an address?    ip addr
3. Is the route correct?       ip route
4. Does DNS resolve?           getent hosts / dig
5. Can I reach the port?       nc -vz / curl -v
6. Is the app listening?       ss -lntp
7. Does the local firewall allow it?  nft / ufw / firewalld
8. Does packet capture support the story? tcpdump
```

The ordering matters. It keeps you from jumping immediately to “the firewall is blocking it.”

## 9. Practical: identify a suspicious outbound connection

Start read-only:

```bash
sudo ss -tpn state established
```

Map a PID to its executable:

```bash
sudo ls -l /proc/<PID>/exe
sudo tr '\0' ' ' < /proc/<PID>/cmdline; echo
```

Inspect the service or parent process:

```bash
ps -o pid,ppid,user,cmd -p <PID>
```

Check recent logs:

```bash
journalctl --since '30 min ago' | grep -Ei 'error|timeout|connect|dns'
```

Do not label an IP “malicious” just because you do not recognize it. Establish process ownership, expected destinations, time, DNS history where available, and the application's role first.


## What I try not to forget

A successful ping, DNS lookup, or TCP connection does not prove that an application is healthy. I try to keep the layers separate in my head:

```text
DNS → route → TCP → TLS → HTTP → application
```

That sounds obvious, but it is very easy to skip straight to the firewall or application configuration when the real problem is one layer earlier.
