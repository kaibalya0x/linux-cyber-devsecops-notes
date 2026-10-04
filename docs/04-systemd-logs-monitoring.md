# 04 — systemd, journald, Services, and Operational Observability

## 1. systemd is both a service manager and an investigation source

Useful commands:

```bash
systemctl list-units --type=service --state=running
systemctl status ssh --no-pager
systemctl is-enabled ssh
systemctl is-active ssh
systemctl cat ssh
```

When a service fails:

```bash
systemctl status ssh --no-pager
journalctl -u ssh -b --no-pager
journalctl -u ssh --since '1 hour ago' --no-pager
```

The `-b` filter is a good way to focus on the current boot.

## 2. Service file anatomy

A simplified unit:

```ini
[Unit]
Description=Example API
After=network-online.target
Wants=network-online.target

[Service]
User=myapp
Group=myapp
ExecStart=/opt/myapp/bin/server
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

After creating or changing a unit:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp
sudo systemctl status myapp --no-pager
```

## 3. Service hardening

systemd can reduce the impact of a compromised service. Depending on the application, useful controls include:

```ini
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=read-only
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
LockPersonality=yes
RestrictSUIDSGID=yes
```

These are not “copy and paste everything” switches. Each can break a legitimate workload. Build the service in a lab, observe failures, then tighten incrementally.

Check the actual applied properties:

```bash
systemctl show myapp | grep -E 'NoNewPrivileges|ProtectSystem|ProtectHome|RestrictAddressFamilies'
```

## 4. journalctl as a timeline tool

Examples:

```bash
journalctl -b
journalctl -b -p warning..alert
journalctl --since 'today'
journalctl --since '2026-10-04 18:00' --until '2026-10-04 19:00'
journalctl -k
journalctl _SYSTEMD_UNIT=ssh.service
journalctl _PID=1234
```

### Follow live events

```bash
journalctl -fu ssh
```

For incident response, prefer time-bounded queries rather than dumping the whole journal into a terminal or ticket.

## 5. Log rotation still matters

On systems using traditional files:

```bash
ls -lh /var/log
sudo logrotate -d /etc/logrotate.conf
```

Know whether your environment sends logs to a central collector. A local attacker with root access can alter local evidence; centralized logging increases resilience.

## 6. Monitoring: alert on behavior, not noise

Useful host signals include:

- privileged account changes;
- new listening sockets;
- failed authentication bursts;
- unexpected service restarts;
- package installation or removal;
- changes to critical configuration;
- unusual outbound destinations;
- repeated process crashes.

Do not create an alert for every `sudo` event. Alerting must include context and a reasonable baseline.

## 7. Practical: service failure drill

Create a safe test service that fails intentionally:

```ini
[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo "intentional lab failure"; exit 1'
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl start lab-failure.service
systemctl status lab-failure.service --no-pager
journalctl -u lab-failure.service -n 30 --no-pager
```

The learning target is not writing a broken service. It is becoming comfortable connecting:

```
unit → process → exit status → journal → next corrective action
```

## 8. Health checklist

```bash
systemctl --failed
journalctl -b -p warning..alert --no-pager
ss -lntup
free -h
df -hT
uptime
```

Run it when the system looks healthy too. Otherwise you have no baseline for “healthy.”


## My usual order when a service breaks

I try not to restart first.

```text
status → journal → unit file → process → configuration → change
```

A restart can make the service come back, but it can also remove useful clues. If the service is already down, the logs and exit status are usually more useful than another restart.
