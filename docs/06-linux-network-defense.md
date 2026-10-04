# 06 — Linux Network Defense and Secure Remote Access

## 1. Build a network picture first

```bash
ip -br addr
ip route
resolvectl status 2>/dev/null || cat /etc/resolv.conf
ss -lntup
```

Think in terms of:

```
interface → address → route → resolver → listener → firewall → application
```

## 2. Bind listeners intentionally

A service bound to `127.0.0.1` is local-only. A service bound to `0.0.0.0` may accept connections on every IPv4 interface.

Check:

```bash
ss -lntp
```

When you see:

```text
127.0.0.1:8080
0.0.0.0:8080
[::]:8080
```

those are materially different exposure patterns.

## 3. SSH secure access pattern

A common administrative pattern is:

```text
administrator
   |
   | SSH key / MFA / device trust
   v
bastion or VPN boundary
   |
   v
server private address
```

The important idea is network-level reduction of attack surface plus strong identity, not simply moving SSH to a strange port.

## 4. SSH key lifecycle

Create a modern key on your workstation:

```bash
ssh-keygen -t ed25519 -C 'admin@lab'
```

Install it into an authorized lab account:

```bash
ssh-copy-id user@lab-host
```

Verify:

```bash
ssh -o PreferredAuthentications=publickey user@lab-host
```

Review key permissions on the server:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## 5. SSH troubleshooting

Run the client in verbose mode:

```bash
ssh -vvv user@host
```

On the server:

```bash
sudo sshd -t
sudo journalctl -u ssh --since '15 min ago' --no-pager
sudo ss -lntp | grep ':22\b'
```

If authentication fails, separate the stages:

```text
DNS → TCP → SSH handshake → host-key trust → user authentication → authorization → shell
```

## 6. Network segmentation on a Linux host

A strong host policy can be thought of as three zones:

```text
management:  SSH / monitoring
application: web / API
internal:    database / message bus / service-to-service
```

Do not allow the web tier to connect everywhere simply because “it might be useful later.” Explicit egress rules are powerful because many attacks need an outbound channel after compromise.

## 7. Network namespace lab

Linux namespaces are a core building block behind container isolation.

Check network namespaces on a host:

```bash
ip netns list
```

Create a disposable namespace:

```bash
sudo ip netns add labns
sudo ip netns exec labns ip link
sudo ip netns del labns
```

The important lesson is isolation of the network view. Containers and network namespaces are related to this concept, though container security requires more controls than namespaces alone.

## 8. Connection triage

```bash
sudo ss -tpn state established
sudo ss -tpn state syn-recv
sudo ss -lntup
```

Questions to answer:

- Which PID owns the socket?
- Which UID runs it?
- Which executable is it?
- Is the destination expected?
- Is the connection persistent?
- Was the service recently restarted?

## 9. Defensive packet capture lab

Create a local HTTP test service:

```bash
python3 -m http.server 8088 --bind 127.0.0.1
```

In another terminal:

```bash
sudo tcpdump -ni lo 'tcp port 8088'
curl http://127.0.0.1:8088/
```

This is a safe way to learn TCP connection setup and HTTP visibility without sniffing somebody else's traffic.
