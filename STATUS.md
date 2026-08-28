# 📊 Lab Status — Single Source of Truth

> Last updated: **2026-08-28**  
> Open this file when you return to the lab. It tells you exactly where you left off.

---

## ✅ Verified & Done

### Infrastructure
- [x] **pfSense** (172.16.0.1) — firewall up, FLARE-VM outbound blocked, admin password changed ✅
- [x] **ELK Stack** (172.16.0.4) — Elasticsearch + Kibana running, TLS enabled
- [x] **DC / AD** (172.16.0.5) — domain `soc.lab` healthy, DNS working, hostname `SOC-Lab-DC`
- [x] **Kali** (172.16.0.11) — network OK, Impacket + CrackMapExec installed and working ✅
- [x] **Win10 Victim** (172.16.0.10) — Sysmon + Winlogbeat **verified running** (session 2026-08-20)
- [x] **Ubuntu Victim** (172.16.0.20) — network OK, Filebeat **verified** (session 2026-08-20)
- [x] **FLARE-VM** (172.16.0.30) — network OK, isolated by design, no telemetry

### Telemetry
- [x] **DC → ELK:** Winlogbeat 8.17.0 running at `C:\winlogbeat\` — ships Security, Sysmon, PowerShell channels
- [x] **Sysmon (DC):** sysmon-modular v4.90 (Olaf Hartong config) installed
- [x] **Sysmon (Win10):** sysmon-modular v4.90 config verified — `C:\Windows\sysmonconfig.xml` confirmed
- [x] **Win10 → ELK:** Winlogbeat running at `C:\Program Files\Winlogbeat\` — confirmed shipping
- [x] **Confirmed index:** `winlogbeat-2026.08.12`, `winlogbeat-2026.08.20`, `winlogbeat-2026.08.25`, `winlogbeat-2026.08.27` — live data verified in Kibana
- [x] **Ubuntu → ELK:** Filebeat 8.19.17 → Logstash `172.16.0.4:5044`
  - `sudo filebeat test config -e` → **Config OK**
  - `sudo filebeat test output -e` → **parse host ✅ | dns ✅ | dial ✅ | talk to server ✅**
  - ⚠️ TLS disabled on Filebeat → Logstash (plain text — acceptable for isolated lab)
- [x] **FLARE-VM:** No telemetry — intentional

### Suricata → ELK (Complete — 2026-08-26)
- [x] **Suricata 7.0.9** installed on pfSense 2.8.1
- [x] Hardware offloading disabled, pfSense rebooted
- [x] LAN (em1) interface configured — EVE JSON logging enabled (DNS, HTTP, Kerberos, SMB, TLS, SSH, JA3/JA3S)
- [x] Rulesets downloaded: ETOpen, Snort GPLv2, Feodo Tracker, ABUSE.ch SSL Blacklist (12h auto-update)
- [x] Suricata running on LAN — green status, IDS-only mode
- [x] EVE Output Type set to `SYSLOG` — forwarding to `172.16.0.4:5140`
- [x] `suricata-eve-2026.08.23` index confirmed in Elasticsearch ✅
- [x] Pipeline `03-suricata-eve.conf` running on port `5045` ✅
- [x] Config documented in `configs/network/suricata-pfsense.md` ✅
- [x] **Issue #1 closed** ✅

### All Logstash Pipelines Green
| Pipeline | Port | Status |
|---|---|---|
| `beats.conf` | 5044 | ✅ Winlogbeat + Filebeat |
| `02-pfsense-syslog.conf` | 5140 | ✅ pfSense system + Suricata syslog |
| `03-suricata-eve.conf` | 5045 | ✅ Suricata EVE JSON |

### Winlogbeat 9.x Fix (2026-08-26)
- [x] Fixed `winlog.event_data.ProcessCreationTime` HTTP 400 indexing error — `remove_field` mutate in `beats.conf`
- [x] `winlogbeat-2026.08.26` → **5,228 documents indexed** with zero errors ✅
- [x] Commit: `f028c11`

### Configs Pushed to Repo (session 2026-08-20)
- [x] `configs/sysmon/sysmonconfig.xml` — sysmon-modular v4.90, MITRE-tagged
- [x] `configs/winlogbeat/dc-winlogbeat.yml` — DC config
- [x] `configs/winlogbeat/win10-winlogbeat.yml` — Win10 config, verified & synced
- [x] `configs/filebeat/filebeat.yml` — Ubuntu victim, Logstash output, v8.19.17 verified
- [x] `configs/network/pfsense-rules.md` — live rules from UI + production hardening section
- [x] `configs/detection-rules/README.md` — placeholder for Kibana rule exports

### Kerberos Audit Policy (DC)
- [x] `Kerberos Authentication Service` — `Success and Failure` confirmed via `auditpol`
- [x] `Kerberos Service Ticket Operations` — `Success and Failure` confirmed (required for EID 4769)

### Docs & Configs (resolved from previous TODO list)
- [x] **Logstash pipeline config** — saved to `configs/logstash/` (`beats-input.conf`, `pfsense-input.conf`, credentials redacted) — session 2026-08-21
- [x] **AD structure** — users, groups, OUs documented in `docs/ad-structure.md` — session 2026-08-21

### Playbooks
- [x] `IR-001` through `IR-004` — brute force, lateral movement, credential dumping, malware execution
- [x] `IR-005-kerberos-attacks.md` — AS-REP Roasting + Kerberoasting (added 2026-08-21)

---

## ❌ Missing / TODO

### 🔴 High Priority
- ✅ ~~**Evidence uploads**~~ — all incident evidence folders up to date (2026-08-28)

### 🟡 Medium Priority
- [ ] **Kibana detection rules** — not exported to `detection/kibana/`
- [ ] **Kibana dashboards** — not exported (Stack Management → Saved Objects → Export `.ndjson`)
- [ ] **pfSense XML backup** — export via Diagnostics > Backup/Restore and commit to repo
- [ ] **MAC addresses** — run `arp -a` on pfSense to populate DHCP static mapping table
- [ ] **Network diagram updated** — reflect IDS/Suricata layer in `assets/diagrams/`

### 🟢 Low Priority
- [ ] **FLARE-VM tool inventory** — document in `infrastructure/flare-vm.md`
- [ ] **Network diagram PNG** — add to `assets/diagrams/`
- [ ] **VLAN segmentation** — flat network, planned for v2.1
- [ ] **DC segmentation rules** — implement post-lab hardening rules from `configs/network/pfsense-rules.md`

---

## ⚠️ Needs Investigation

| Item | Question | Action |
|------|----------|--------|
| Win10 Winlogbeat index | Is Win10 data landing in its own index? | Check Kibana index management |
| Suricata syslog truncation | FreeBSD syslog truncates at 480 bytes — long EVE JSON events may arrive broken | Monitor `suricata-*` index for parse failures; consider syslog-ng or log forwarder VM as long-term fix |

---

## 🎯 Incident Progress

| ID | Name | MITRE | Status |
|----|------|-------|--------|
| INC-002 | AS-REP Roasting | T1558.004 | ✅ Complete (2026-08-12) |
| INC-003 | Kerberoasting | T1558.003 | ✅ Complete (2026-08-20) |
| INC-004 | Pass-the-Hash Lateral Movement | T1550.002 | ✅ Complete (2026-08-25) |
| INC-005 | DCSync Attack | T1003.006 | ✅ **Complete (2026-08-27)** |
| INC-006 | Malware Detonation + C2 Beacon | T1071.001 | 🔲 Next up |
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
| Sigma rule | `detection/sigma/T1558.004-asrep-roasting.yml` — pushed | ✅ |
| Writeup | `incidents/INC-002-asrep-roasting/README.md` | ✅ |
| Evidence | 4 screenshots in `incidents/INC-002-asrep-roasting/evidence/` | ✅ |

---

## ✅ INC-003 — Kerberoasting (Complete)

| Check | What Was Done | Result |
|-------|--------------|--------|
| Service account | `svc_http` created with SPN `HTTP/soc-lab-dc.soc.lab` | ✅ |
| TGS requested | `impacket-GetUserSPNs` — `$krb5tgs$23$*` hash captured | ✅ |
| Hash cracked | Hashcat `-m 13100` — 1/1 cracked | ✅ |
| ELK detection | Event 4769 + `TicketEncryptionType: 0x17` confirmed in Kibana | ✅ |
| Detection index | `winlogbeat-2026.08.20` — record `52849` | ✅ |
| Sigma rule | `detection/sigma/T1558.003-kerberoasting.yml` — pushed | ✅ |
| Writeup | `incidents/INC-003-kerberoasting/README.md` | ✅ |
| detection.md | `incidents/INC-003-kerberoasting/detection.md` | ✅ |
| timeline.md | `incidents/INC-003-kerberoasting/timeline.md` | ✅ |
| remediation.md | `incidents/INC-003-kerberoasting/remediation.md` | ✅ |
| Evidence screenshots | `incidents/INC-003-kerberoasting/evidence/` | ✅ Uploaded (2026-08-28) |

---

## ✅ INC-004 — Pass-the-Hash (Complete — 2026-08-25)

| Check | What Was Done | Result |
|-------|--------------|--------|
| Tool verified | CrackMapExec confirmed working on Kali | ✅ |
| NTLM hash generated | `217cac874bc6e41a6fec9b06d2eee7d5` via Python hashlib | ✅ |
| PtH executed | CME → Win10 (172.16.0.10) — `(Pwn3d!)` | ✅ |
| RCE confirmed | `whoami` → `soc\administrator`, `hostname` → `SOC-Lab-Endpoint` | ✅ |
| Net recon | `net user`, `ipconfig /all` — full network config exposed | ✅ |
| Lateral movement | Subnet scan `172.16.0.0/24` — Win10 AND DC both `(Pwn3d!)` | ✅ |
| ELK detection | 40× EID 4624, LogonType 3, NTLM, source 172.16.0.11 — `winlogbeat-2026.08.25` | ✅ |
| Evidence screenshot | 40-event / last 15h Kibana view | ✅ |
| Sigma rule | `detection/sigma/T1550.002-pass-the-hash.yml` — pushed | ✅ |
| Writeup | `incidents/INC-004-pass-the-hash/README.md` | ✅ |
| detection.md | `incidents/INC-004-pass-the-hash/detection.md` | ✅ |
| timeline.md | `incidents/INC-004-pass-the-hash/timeline.md` | ✅ |
| remediation.md | `incidents/INC-004-pass-the-hash/remediation.md` | ✅ |
| Evidence upload | `incidents/INC-004-pass-the-hash/evidence/` | ✅ Uploaded (2026-08-28) |

---

## ✅ INC-005 — DCSync Attack (Complete — 2026-08-27)

| Check | What Was Done | Result |
|-------|--------------|--------|
| Audit policy | `auditpol` — `Directory Service Access: Success and Failure` enabled on DC | ✅ |
| DCSync rights granted | ADUC → Delegate Control → `svc_asrep` granted `Replicating Directory Changes` + `Replicating Directory Changes All` on `soc.lab/` | ✅ |
| Attack executed | `impacket-secretsdump soc.lab/svc_asrep@172.16.0.5` — full domain dump via DRSUAPI | ✅ |
| Hashes captured | `Administrator`, `krbtgt`, `svc_asrep`, `svc_http`, `SOC-LAB-DC$`, `SOC-LAB-ENDPOIN$` | ✅ |
| `krbtgt` hash | `0c0c6f91a7fa8c09826af3a88bf0224e` — Golden Ticket capable | ✅ |
| ELK detection | 23× EID 4662 from `svc_asrep` on `SOC-Lab-DC` at 14:13:09 — `winlogbeat-2026.08.27` | ✅ |
| GUIDs confirmed | `1131f6aa` (Replicating Directory Changes) present in all events | ✅ |
| Sigma rule | `detection/sigma/T1003.006-dcsync.yml` — pushed & validated via sigma-cli | ✅ |
| Kibana detection rule | `DCSync Attack — Non-DC Account Requesting AD Replication` — Critical, Risk 99, live & succeeded | ✅ |
| Writeup | `incidents/INC-005-dcsync/README.md` | ✅ |
| detection.md | `incidents/INC-005-dcsync/detection.md` | ✅ |
| timeline.md | `incidents/INC-005-dcsync/timeline.md` | ✅ |
| remediation.md | `incidents/INC-005-dcsync/remediation.md` | ✅ |
| Evidence upload | `incidents/INC-005-dcsync/evidence/` | ✅ Uploaded (2026-08-28) |

---

## 🔲 INC-006 — Malware Detonation + C2 Beacon (Next)

**Pre-requisites:**
- [x] Suricata deployed on pfSense for network-level C2 detection ✅ (complete 2026-08-26)
- [ ] FLARE-VM ready for malware analysis
- [ ] C2 framework set up on Kali (Metasploit or Sliver)

**Attack plan:**
- Generate payload on Kali → detonate on FLARE-VM → establish C2 beacon
- Detect: Sysmon EID 1 (process create), EID 3 (network connect), pfSense Suricata alerts
- MITRE: T1071.001 — Application Layer Protocol: Web Protocols
