# 🏗️ Lab Architecture

## VM Inventory

| Hostname | IP | Role | OS | Telemetry |
|----------|----|------|----|----------|
| pfSense | 172.16.0.1 | Firewall / Gateway | pfSense CE | — |
| ELK | 172.16.0.4 | SIEM | Ubuntu 22.04 | — |
| SOC-Lab-DC | 172.16.0.5 | Domain Controller | Windows Server 2022 | Sysmon + Winlogbeat |
| Win10 | 172.16.0.10 | Victim (Windows) | Windows 10 | Sysmon + Winlogbeat (verified) |
| Kali | 172.16.0.11 | Attacker | Kali Linux Rolling | — |
| Ubuntu Victim | 172.16.0.20 | Victim (Linux) | Ubuntu 22.04 | Filebeat |
| FLARE-VM | 172.16.0.30 | Malware Analysis | Windows 10 + FLARE | None (isolated by design) |

## Domain
- **Name:** `soc.lab`
- **DC IP:** 172.16.0.5
- **DNS:** Handled by DC

## Firewall Rules (pfSense)

| Rule | Source | Destination | Action |
|------|--------|-------------|--------|
| BLOCK-FLARE-VM-OUTBOUND | 172.16.0.30 | any | Block |
| Default LAN | LAN net | any | Allow |

> The redacted pfSense export is maintained in [`configs/network/pfsense-backup.xml`](../configs/network/pfsense-backup.xml).

## Data Flow

```
[DC / Win10]     ──Winlogbeat──▶  [ELK :9200 or Logstash :5044]
[Ubuntu Victim]  ──Filebeat────▶  [ELK]
[Kali]           ── no shipping    (attacker — intentional)
[FLARE-VM]       ── no shipping    (isolated malware analysis — intentional)
```

## ELK Index Design

| Index Pattern | Source | Status |
|---------------|--------|--------|
| `winlogbeat-*` | DC, Win10 | Live and verified |
| `filebeat-*` | Ubuntu Victim | Live via Logstash `172.16.0.4:5044` |
| `suricata-*` | pfSense | Live via EVE JSON and Logstash `172.16.0.4:5045` |

## Folder Convention — incidents/ vs threat-scenarios/

> **Rule:** `incidents/` is the single canonical write-up for every incident (IR narrative, detection logic, timeline, evidence, remediation). `threat-scenarios/` never duplicates it — it only links back to `incidents/` and may add red-team-only detail (attack commands, prerequisites, tool setup) that has no place in a blue-team IR record.

## Future Improvements
- [ ] VLAN segmentation (management / lab / attacker / malware)
- [x] Suricata on pfSense (network IDS)
- [ ] Dedicated out-of-band management network
