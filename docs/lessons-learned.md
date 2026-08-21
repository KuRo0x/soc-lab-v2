# 📓 Lessons Learned / Engineering Log

> Updated after every incident or significant lab change.  
> This is an engineering log — what broke, why, what was decided, and what would be done differently.

---

## [2026-08-21] — INC-003 Kerberoasting

**Observation:** `impacket-GetUserSPNs` returned a TGS hash immediately after the SPN was set — no special permissions needed beyond a valid domain user.

**Root cause:** Any authenticated domain user can request a TGS for any SPN. This is by design in Kerberos but becomes a vulnerability when service accounts use weak passwords and RC4 encryption (etype 0x17).

**Decision/Fix:** Documented in INC-003. Real mitigations: enforce AES-only Kerberos (`msDS-SupportedEncryptionTypes`), use Group Managed Service Accounts (gMSA), enforce 25+ char service account passwords.

**Lesson:** RC4 (`0x17`) in EID 4769 is the detection signal — modern environments should only see AES (`0x12`/`0x11`). Any RC4 TGS request in a hardened environment is an immediate IOC worth alerting on.

---

## [2026-08-20] — Winlogbeat Index Naming

**Observation:** Win10 and DC both ship to ELK but land in the same daily index pattern (`winlogbeat-YYYY.MM.dd`). No per-host index separation.

**Root cause:** Default Winlogbeat config uses `%{[@metadata][beat]}-%{+YYYY.MM.dd}` which groups all beats of the same type together.

**Decision:** Accepted for now — host filtering in Kibana using `host.name` field is sufficient for the lab scale. Per-host indices add operational overhead with no meaningful benefit at this scale.

**Lesson:** At scale (50+ hosts) per-host or per-team indices become important for access control and retention policies. For a home lab, a single index with good field tagging is fine.

---

## [2026-08-12] — INC-002 AS-REP Roasting

**Observation:** Kali clock skew caused `impacket-GetNPUsers` to fail initially with a Kerberos KRB_AP_ERR_SKEW error before chrony was configured.

**Root cause:** Kerberos requires clocks within 5 minutes of the KDC. Kali's default NTP was drifting against the DC.

**Decision/Fix:** Installed `chrony` on Kali, pointed it at the DC (`172.16.0.5`). Offset dropped to `0.000002620s`.

**Lesson:** Always sync Kali to the DC before running any Kerberos-based attack tooling. Make this a lab startup checklist item.

---

## [2026-08-12] — AS-REP Detection Gap

**Observation:** EID 4768 fires for *all* TGT requests, not just AS-REP roasting attempts. High noise in a real environment.

**Root cause:** Windows does not emit a dedicated event for `DoesNotRequirePreAuth` abuse. The signal is in the `TicketEncryptionType: 0x17` field combined with no pre-auth flag.

**Decision/Fix:** Sigma rule scoped to `EncryptionType: 0x17` + `PreAuthType: 0` to reduce false positives.

**Lesson:** Detection engineering is about field-level precision, not just event IDs. EID alone is rarely enough.

---

## [2026-08-11] — FLARE-VM Firewall Behaviour (✅ Resolved)

**Observation:** FLARE-VM (172.16.0.30) reached ELK and DC directly over LAN even with pfSense outbound block rule active.

**Root cause:** Intra-subnet traffic does not traverse pfSense — only routed traffic does. Hosts on the same `/24` communicate at Layer 2, bypassing the firewall entirely.

**Decision:** Accepted for the lab. FLARE-VM isolation goal is internet access prevention and outbound exfiltration blocking, not full LAN isolation. Full isolation would require a separate VLAN with inter-VLAN ACLs on pfSense.

**Lesson:** Firewalls only control traffic that passes *through* them. Proper host isolation requires VLAN segmentation — a flat network with firewall rules is not true isolation. Logged in TODO as a v2.1 improvement.

---

## [2026-08-11] — Ubuntu Filebeat Output (✅ Resolved)

**Observation:** Ubuntu Victim Filebeat had `output.elasticsearch` commented out. Logs appeared to be running but destination was unclear.

**Root cause:** Default Filebeat config ships with Elasticsearch output enabled and Logstash output commented out. Lab uses Logstash as the ingestion point, so the config needed inverting.

**Decision/Fix:** Corrected `filebeat.yml` — Logstash output enabled (`172.16.0.4:5044`), Elasticsearch output disabled. Verified with `sudo filebeat test output` — all checks passed.

**Lesson:** Always run `filebeat test output` after any config change. Silent failures (service running but shipping nowhere) are harder to debug than loud failures.

---

## [2026-08-11] — BloodHound Not Installed on Kali

**Observation:** BloodHound not present on Kali despite being a core AD enumeration tool.

**Decision:** Deferred — not required for INC-002 or INC-003. Will install when lateral movement and privilege escalation scenarios begin (INC-004+).

**Action:** `sudo apt install bloodhound -y` before starting INC-004.

---

## Template

```
## [YYYY-MM-DD] — Topic

**Observation:** What you noticed.
**Root cause:** Why it happened.
**Decision/Fix:** What you did.
**Lesson:** What you'd do differently next time.
```
