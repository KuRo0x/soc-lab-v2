# Changelog

All notable changes to this lab are documented here.
Format: `[YYYY-MM-DD] — What changed and why`

---

## [2026-08-30] — README overhaul
- Added badges (License, Status, MITRE ATT&CK, ELK 8.x, VMware)
- Centered title and badge block for symmetric layout
- Replaced ASCII architecture diagram with `assets/diagrams/network-diagram.png`
- Replaced TODO labels in Incident Index and Tech Stack with `Planned`
- Added Connect section with GitHub + LinkedIn links and remote contractor pitch
- Marked INC-004 (Pass-the-Hash) and INC-005 (DCSync) as ✅ Complete in README

## [2026-08-28] — Evidence uploads + network diagram + pfSense backup
- Uploaded evidence screenshots for INC-003, INC-004, INC-005
- `assets/diagrams/network-diagram.png` — full lab topology with telemetry flows, attack paths, Suricata layer, FLARE-VM isolation
- `configs/network/pfsense-backup.xml` — exported pfSense config, secrets redacted
- `docs/dhcp-static-map.md` — ARP table, all LAN hosts mapped

## [2026-08-27] — INC-005 DCSync Attack (Complete)
- Granted DCSync rights to `svc_asrep` via ADUC Delegate Control
- Executed `impacket-secretsdump` — full domain dump via DRSUAPI
- Detected 23× EID 4662 from non-DC account in Kibana (`winlogbeat-2026.08.27`)
- Sigma rule `detection/sigma/T1003.006-dcsync.yml` pushed and validated via sigma-cli
- Kibana detection rule live — Critical severity, Risk 99
- Full writeup + detection.md + timeline.md + remediation.md pushed

## [2026-08-26] — Suricata IDS + Winlogbeat 9.x fix
- Suricata 7.0.9 installed on pfSense, LAN interface, IDS-only mode
- EVE JSON logging enabled (DNS, HTTP, Kerberos, SMB, TLS, SSH, JA3/JA3S)
- Rulesets: ETOpen, Snort GPLv2, Feodo Tracker, ABUSE.ch SSL Blacklist (12h auto-update)
- `suricata-eve-2026.08.23` index confirmed in Elasticsearch
- Pipeline `03-suricata-eve.conf` running on port 5045
- Fixed Winlogbeat `ProcessCreationTime` HTTP 400 indexing error — `remove_field` mutate in `beats.conf`
- `winlogbeat-2026.08.26` → 5,228 documents indexed with zero errors

## [2026-08-25] — INC-004 Pass-the-Hash (Complete)
- CrackMapExec PtH → Win10 + DC both `(Pwn3d!)`
- Detected 40× EID 4624, LogonType 3, NTLM from 172.16.0.11 in Kibana
- Sigma rule `detection/sigma/T1550.002-pass-the-hash.yml` pushed
- Full writeup + detection.md + timeline.md + remediation.md pushed

## [2026-08-21] — Logstash configs + AD structure docs
- Logstash pipeline configs saved to `configs/logstash/`
- AD structure documented in `docs/ad-structure.md`
- IR-005 Kerberos attacks playbook added

## [2026-08-20] — INC-003 Kerberoasting (Complete) + Win10 telemetry verified
- `svc_http` SPN created, TGS hash captured and cracked via Hashcat
- EID 4769 + EncType 0x17 detected in Kibana (`winlogbeat-2026.08.20`)
- Sigma rule `detection/sigma/T1558.003-kerberoasting.yml` pushed
- Win10 Sysmon + Winlogbeat verified running
- Ubuntu Filebeat verified — output to Logstash 172.16.0.4:5044
- Configs pushed: sysmon, winlogbeat (DC + Win10), filebeat, pfsense-rules

## [2026-08-12] — INC-002 AS-REP Roasting (Complete)
- `svc_asrep` created with `DoesNotRequirePreAuth=true`
- Hash captured via `impacket-GetNPUsers`, cracked with Hashcat `-m 18200`
- EID 4768 + EncType 0x17 detected in Kibana (`winlogbeat-2026.08.12`)
- Sigma rule `detection/sigma/T1558.004-asrep-roasting.yml` pushed
- Chrony installed on Kali — clock offset `0.000002620s` to DC

## [2026-08-11] — Initial build
- Deployed pfSense, ELK, DC (soc.lab), Kali, Win10, Ubuntu Victim, FLARE-VM
- Sysmon deployed on DC: sysmon-modular v4.90 (Olaf Hartong), balanced verbosity, MITRE ATT&CK tagging
- Winlogbeat deployed on DC, shipping to ELK
- Filebeat deployed on Ubuntu Victim
- FLARE-VM isolated from outbound traffic via pfSense block rule — no telemetry by design
- Repo initialized with full enterprise-grade documentation structure
