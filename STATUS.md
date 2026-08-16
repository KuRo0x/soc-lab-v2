# 📊 Lab Status — Single Source of Truth

> Last updated: 2026-08-16
> Open this file when you return to the lab. It tells you exactly where you left off.

---

## ✅ Verified & Done

### Infrastructure
- [x] **pfSense** (172.16.0.1) — firewall up, FLARE-VM outbound blocked
- [x] **ELK Stack** (172.16.0.4) — Elasticsearch + Kibana running, TLS enabled
- [x] **DC / AD** (172.16.0.5) — domain `soc.lab` healthy, DNS working, hostname `SOC-Lab-DC`
- [x] **Kali** (172.16.0.11) — network OK, Impacket installed and working
- [x] **Ubuntu Victim** (172.16.0.20) — network OK, Filebeat running
- [x] **FLARE-VM** (172.16.0.30) — network OK, isolated by design, no telemetry

### Telemetry
- [x] DC → ELK: Winlogbeat 8.17.0 running at `C:\winlogbeat\` — ships Security, Sysmon, PowerShell channels
- [x] Sysmon: sysmon-modular v4.90 (Olaf Hartong config) installed on DC
- [x] Confirmed index: `winlogbeat-2026.08.12` — live data verified in Kibana
- [x] Ubuntu → ELK: Filebeat confirmed shipping to **Logstash at 172.16.0.4:5044** — `sudo filebeat test output` passed (parse host ✅, DNS ✅, dial ✅, talk to server ✅)
  - ⚠️ Note: TLS disabled on Filebeat → Logstash transport (plain text, acceptable for isolated lab)
- [x] FLARE-VM: No telemetry — intentional

### Kerberos Audit Policy (DC)
- [x] `Kerberos Authentication Service` — `Success and Failure` confirmed via `auditpol`

---

## ❌ Missing / TODO

### 🔴 High Priority
- [ ] **Win10 Victim** (172.16.0.10) — Sysmon + Winlogbeat NOT verified
- [ ] **BloodHound on Kali** — not installed

### 🟡 Medium Priority
- [ ] **pfSense rules** — full ruleset not documented in repo
- [ ] **Logstash pipeline config** — not saved to repo
- [ ] **AD structure** — users, OUs, groups not fully documented
- [ ] **Kibana dashboards** — not exported to repo
- [ ] **CrackMapExec / Metasploit on Kali** — not verified

### 🟢 Low Priority
- [ ] **FLARE-VM tool inventory** — document in `infrastructure/flare-vm.md`
- [ ] **Suricata on pfSense** — IDS not deployed
- [ ] **Network diagram PNG** — add to `assets/diagrams/`
- [ ] **VLAN segmentation** — flat network, planned for v2.1

---

## ⚠️ Needs Investigation

| Item | Question | Action |
|------|----------|--------|
| Win10 Victim | Sysmon + Winlogbeat installed? | Verify on 172.16.0.10 |
| Kali tools | CME + Metasploit present? | `which crackmapexec msfconsole` on 172.16.0.11 |

---

## 🎯 Incident Progress

| ID | Name | MITRE | Status |
|----|------|-------|--------|
| INC-001 | LLMNR Poisoning + NTLM Relay | T1557.001 | 🔲 Not started |
| INC-002 | AS-REP Roasting | T1558.004 | ✅ Complete |
| INC-003 | Kerberoasting | T1558.003 | 🔲 Not started |
| INC-004 | Pass-the-Hash Lateral Movement | T1550.002 | 🔲 Not started |
| INC-005 | DCSync Attack | T1003.006 | 🔲 Not started |
| INC-006 | Malware Detonation + C2 Beacon | T1071.001 | 🔲 Not started |
| INC-007 | Phishing → Macro → PowerShell | T1566.001 | 🔲 Not started |

---

## ✅ INC-002 — AS-REP Roasting (Complete)

| Check | What Was Done | Result |
|-------|--------------|--------|
| Vulnerable user | `svc_asrep` created, `DoesNotRequirePreAuth=true` | ✅ |
| Audit policy | `auditpol` verified: `Success and Failure` | ✅ |
| Winlogbeat pipeline | Security channel confirmed, 4768 landed in `winlogbeat-2026.08.12` | ✅ |
| Clock skew | Chrony installed on Kali, offset `0.000002620s` to DC | ✅ |
| Attack executed | `impacket-GetNPUsers` — hash captured | ✅ |
| Hash cracked | Hashcat `-m 18200` — `Status: Cracked` | ✅ |
| ELK detection | Event 4768 + `TicketEncryptionType: 0x17` confirmed in Kibana | ✅ |
| Sigma rule | `detection/sigma/T1558.004-asrep-roasting.yml` — written and pushed | ✅ |
| Writeup | `threat-scenarios/INC-002-asrep-roasting/README.md` | ✅ |

**Next:** INC-003 — Kerberoasting
