# 🏗️ Lab Architecture

## VM Inventory

| Hostname | IP | Role | OS | Telemetry |
|----------|----|------|----|----------|
| pfSense | 172.16.0.1 | Firewall / Gateway | pfSense CE | — |
| ELK | 172.16.0.4 | SIEM | Ubuntu 22.04 | — |
| DC01 | 172.16.0.5 | Domain Controller | Windows Server 2019 | Sysmon + Winlogbeat |
| Win10 | 172.16.0.10 | Victim (Windows) | Windows 10 | Sysmon + Winlogbeat (TODO: verify) |
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

> TODO: Export full ruleset from pfSense (Diagnostics > Backup) and paste here.

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
| `winlogbeat-*` | DC, Win10 | DC verified; Win10 TODO |
| `filebeat-*` | Ubuntu Victim | Running; output destination TBC |

## Future Improvements
- [ ] VLAN segmentation (management / lab / attacker / malware)
- [ ] Suricata on pfSense (network IDS)
- [ ] Dedicated out-of-band management network
