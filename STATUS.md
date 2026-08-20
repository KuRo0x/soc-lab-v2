# 📊 Lab Status — Single Source of Truth

> Last updated: **2026-08-20**  
> Open this file when you return to the lab. It tells you exactly where you left off.

---

## ✅ Verified & Done

### Infrastructure
- [x] **pfSense** (172.16.0.1) — firewall up, FLARE-VM outbound blocked
  - ⚠️ Admin password still set to default `pfsense` — **change this**
- [x] **ELK Stack** (172.16.0.4) — Elasticsearch + Kibana running, TLS enabled
- [x] **DC / AD** (172.16.0.5) — domain `soc.lab` healthy, DNS working, hostname `SOC-Lab-DC`
- [x] **Kali** (172.16.0.11) — network OK, Impacket installed and working
- [x] **Win10 Victim** (172.16.0.10) — Sysmon + Winlogbeat **verified running** (session 2026-08-20)
- [x] **Ubuntu Victim** (172.16.0.20) — network OK, Filebeat **verified** (session 2026-08-20)
- [x] **FLARE-VM** (172.16.0.30) — network OK, isolated by design, no telemetry

### Telemetry
- [x] **DC → ELK:** Winlogbeat 8.17.0 running at `C:\winlogbeat\` — ships Security, Sysmon, PowerShell channels
- [x] **Sysmon (DC):** sysmon-modular v4.90 (Olaf Hartong config) installed
- [x] **Sysmon (Win10):** sysmon-modular v4.90 config verified — `C:\Windows\sysmonconfig.xml` confirmed
- [x] **Win10 → ELK:** Winlogbeat running at `C:\Program Files\Winlogbeat\` — confirmed shipping
- [x] **Confirmed index:** `winlogbeat-2026.08.12` — live data verified in Kibana
- [x] **Ubuntu → ELK:** Filebeat 8.19.17 → Logstash `172.16.0.4:5044`
  - `sudo filebeat test config -e` → **Config OK**
  - `sudo filebeat test output -e` → **parse host ✅ | dns ✅ | dial ✅ | talk to server ✅**
  - ⚠️ TLS disabled on Filebeat → Logstash (plain text — acceptable for isolated lab)
- [x] **FLARE-VM:** No telemetry — intentional

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

---

## ❌ Missing / TODO

### 🔴 High Priority
- [ ] **INC-004 Pass-the-Hash** — next incident

### 🟡 Medium Priority
- [ ] **Logstash pipeline config** — not saved to repo (`/etc/logstash/conf.d/` on ELK)
- [ ] **Kibana dashboards** — not exported (Stack Management → Saved Objects → Export `.ndjson`)
- [ ] **Kibana detection rules** — not exported to `detection/kibana/`
- [ ] **AD structure** — users, OUs, groups not documented in `docs/`
- [ ] **CrackMapExec / Metasploit on Kali** — not verified (`which crackmapexec msfconsole`)
- [ ] **pfSense password** — still default `pfsense` — change via System > User Manager
- [ ] **pfSense XML backup** — export via Diagnostics > Backup/Restore and commit to repo
- [ ] **MAC addresses** — run `arp -a` on pfSense to populate DHCP static mapping table

### 🟢 Low Priority
- [ ] **FLARE-VM tool inventory** — document in `infrastructure/flare-vm.md`
- [ ] **Suricata on pfSense** — IDS not deployed
- [ ] **Network diagram PNG** — add to `assets/diagrams/`
- [ ] **VLAN segmentation** — flat network, planned for v2.1
- [ ] **DC segmentation rules** — implement post-lab hardening rules from `configs/network/pfsense-rules.md`

---

## ⚠️ Needs Investigation

| Item | Question | Action |
|------|----------|--------|
| Kali tools | CME + Metasploit present? | `which crackmapexec msfconsole` on 172.16.0.11 |
| Win10 Winlogbeat index | Is Win10 data landing in its own index? | Check Kibana index management |

---

## 🎯 Incident Progress

| ID | Name | MITRE | Status |
|----|------|-------|--------|
| INC-001 | LLMNR Poisoning + NTLM Relay | T1557.001 | ✅ Complete |
| INC-002 | AS-REP Roasting | T1558.004 | ✅ Complete |
| INC-003 | Kerberoasting | T1558.003 | ✅ **Complete** |
| INC-004 | Pass-the-Hash Lateral Movement | T1550.002 | 🔲 **Next up** |
| INC-005 | DCSync Attack | T1003.006 | 🔲 Not started |
| INC-006 | Malware Detonation + C2 Beacon | T1071.001 | 🔲 Not started |
| INC-007 | Phishing → Macro → PowerShell | T1566.001 | 🔲 Not started |

---

## ✅ INC-001 — LLMNR Poisoning + NTLM Relay (Complete)

| Check | What Was Done | Result |
|-------|--------------|--------|
| Responder setup | Responder running on Kali, LLMNR/NBT-NS listeners active | ✅ |
| NTLM hash captured | NTLMv2 hash from Win10 victim captured | ✅ |
| Hash cracked | Hashcat cracked NTLMv2 hash | ✅ |
| ELK detection | Event 4648 / Sysmon EID 3 confirmed in Kibana | ✅ |
| Writeup | `incidents/INC-001-llmnr-poisoning/` | ✅ |

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
| Writeup | `threat-scenarios/INC-002-asrep-roasting/README.md` | ✅ |

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

---

## 🔲 INC-004 — Pass-the-Hash (Next)

**Pre-requisites:**
- [ ] Verify CrackMapExec is installed on Kali: `which crackmapexec`
- [ ] Confirm a cracked NTLM hash is available from INC-001 or INC-002

**Attack steps (from Kali):**
```bash
crackmapexec smb 172.16.0.10 -u Administrator -H <NTLM_HASH>
```

**Detection:** EID `4624` with `LogonType: 3` and `AuthenticationPackageName: NTLM` in Kibana

**Deliverables:**
- `incidents/INC-004-pass-the-hash/` writeup
- `detection/sigma/T1550.002-pass-the-hash.yml`
