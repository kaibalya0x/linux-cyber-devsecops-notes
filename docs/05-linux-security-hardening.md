# 05 — Linux Security Hardening: A Practical Baseline

> Hardening is risk reduction, not a configuration contest. Apply controls in context, test them, and keep a rollback path.

Ubuntu's security guidance explicitly recommends a layered approach using users/groups, firewalls, AppArmor and other controls rather than relying on a single defense.
Reference: https://ubuntu.com/server/docs/explanation/intro-to/security/

## 1. Start with inventory

Before hardening, capture:

```bash
hostnamectl
cat /etc/os-release
uname -r
systemctl list-units --type=service --state=running
ss -lntup
sudo ufw status verbose 2>/dev/null || true
sudo nft list ruleset 2>/dev/null | head -n 200
```

You cannot harden what you have not inventoried.

## 2. Update strategy

Security updates are part of the control plane, but blind updates are not a strategy.

Record:

```bash
apt-cache policy
apt list --upgradable
uname -r
```

For servers, consider how you handle kernel reboots and services requiring restart. Tools such as `needrestart` can help on Debian/Ubuntu systems, but change windows and application validation remain operational decisions.

## 3. SSH baseline

Inspect before editing:

```bash
sudo sshd -t
sudo sshd -T | sort | less
```

Common goals are:

- disable direct root login where operationally appropriate;
- prefer key-based authentication for administrators;
- restrict who may connect;
- avoid obsolete algorithms;
- use a dedicated administrative path or network boundary;
- log authentication activity.

Example checks:

```bash
sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|pubkeyauthentication|maxauthtries|allowusers|allowgroups'
```

Do not change SSH remotely unless you have an out-of-band recovery path or a second tested session. A typo can lock you out.

## 4. Firewalling

Use one firewall control plane intentionally. On Ubuntu, UFW is a user-friendly frontend; nftables is the underlying modern packet-filtering framework.

UFW inspection:

```bash
sudo ufw status numbered
sudo ufw status verbose
```

nftables inspection:

```bash
sudo nft list ruleset
```

The secure design principle is not “close every port.” It is “expose only what the workload needs, from the networks that need it.”

## 5. AppArmor

Ubuntu ships AppArmor and uses per-application profiles to add mandatory access control on top of traditional UNIX permissions.

Check status:

```bash
sudo aa-status
```

Inspect profiles:

```bash
ls -1 /etc/apparmor.d/
```

Operational modes include complain (log/learn) and enforce (block + log). See: https://ubuntu.com/server/docs/how-to/security/apparmor/

A useful workflow is:

```
observe → identify required access → create/adjust profile → complain mode → validate → enforce → monitor
```

## 6. SELinux awareness

On RHEL-family environments, SELinux is a first-class security control. Learn to read the label and enforcement state before changing anything:

```bash
getenforce
sestatus
ls -Z /var/www/html
```

When a file permission looks correct but access is denied, SELinux context is a strong suspect.

Do not “fix” SELinux problems by disabling SELinux. Find the policy reason, correct labeling/policy, and document the change.

## 7. Auditing with auditd

Check whether audit is active:

```bash
sudo systemctl status auditd --no-pager
sudo auditctl -s
```

Search example events:

```bash
sudo ausearch -m USER_LOGIN -ts recent
sudo ausearch -m USER_CMD -ts recent
```

The exact event set depends on the distribution's baseline and your requirements. Audit rules should support a defined detection or compliance objective rather than blindly logging everything.

## 8. File integrity: think in terms of change detection

For a small lab, create a known-good hash set:

```bash
sha256sum /etc/ssh/sshd_config > /tmp/sshd_config.sha256
sha256sum -c /tmp/sshd_config.sha256
```

This is not a full file-integrity monitoring system, but it teaches the underlying idea.

## 9. Kernel exposure: inspect before changing

```bash
sysctl -a 2>/dev/null | grep -E 'net\.ipv4\.conf|kernel\.yama'
```

Never apply a kernel hardening value because it appeared in a random checklist. Confirm what it protects, what it breaks, and whether your application needs it.

## 10. Sudo hygiene

Review:

```bash
sudo -l
sudo visudo
sudo ls -la /etc/sudoers.d/
```

Keep administrative rights explicit and reviewable. Avoid broad shell escapes hidden inside seemingly narrow command permissions.

## 11. Secure baseline checklist

Use this as a review sheet rather than a “one command harden script”:

```text
[ ] Host role documented
[ ] Packages and kernel supported
[ ] Unused services disabled
[ ] SSH reviewed and tested
[ ] Firewall policy documented
[ ] MAC control enabled (AppArmor/SELinux where applicable)
[ ] Privileged users reviewed
[ ] sudo policy reviewed
[ ] Logs retained centrally where appropriate
[ ] Time synchronization healthy
[ ] Backups tested
[ ] Recovery path documented
[ ] Security updates monitored
```

## 12. A hardening rule worth remembering

If a security control cannot be explained in one sentence, cannot be tested, and has no rollback plan, it probably does not belong in an automated hardening script yet.


## A practical reminder

There is no single Linux hardening checklist that fits every machine. A server running SSH, a desktop workstation, and a small lab VM have different needs.

I prefer to make one change at a time, record what changed, test the application, and keep a rollback path. It is slower than copying a huge hardening script, but it is much easier to understand what actually helped and what broke the system.
