# 🛡️ SOC Home Lab v2

> **Advanced, professional-grade SOC lab built for real-world detection engineering, threat hunting, incident response, and malware analysis.**

---

## 📋 Lab Overview

| Property | Value |
|----------|-------|
| **Domain** | `soc.lab` |
| **Network** | `172.16.0.0/24` |
| **Gateway / Firewall** | pfSense — `172.16.0.1` |
| **SIEM** | ELK Stack (Elasticsearch + Kibana + Logstash) — `172.16.0.4` |
| **Domain Controller** | Windows Server 2019 — `172.16.0.5` |
| **Attacker** | Kali Linux — `172.16.0.11` |
| **Victim (Windows)** | Windows 10 — `172.16.0.10` |
| **Victim (Linux)** | Ubuntu 22.04 — `172.16.0.20` |
| **Malware Analysis** | FLARE-VM — `172.16.0.30` (isolated) |

---

## 🗂️ Repository Structure

```
soc-lab-v2/
├── README.md                    # This file — lab overview & status
├── STATUS.md                    # ✅ What's done / ❌ What's missing
├── infrastructure/
│   ├── network-diagram.md       # Network topology & VLAN design
│   ├── pfsense.md               # pfSense config, rules, firewall policy
│   ├── elk.md                   # ELK stack setup, indices, dashboards
│   ├── dc.md                    # Domain Controller — AD, DNS, GPO
│   ├── kali.md                  # Attacker VM — tools & usage
│   ├── win10-victim.md          # Windows 10 victim — Sysmon + Winlogbeat
│   ├── ubuntu-victim.md         # Ubuntu victim — Filebeat config
│   └── flare-vm.md              # FLARE-VM — isolated malware analysis
├── configs/
│   ├── sysmon/
│   │   └── sysmonconfig.xml     # SwiftOnSecurity sysmon-modular v4.90
│   ├── winlogbeat/
│   │   └── winlogbeat.yml       # Winlogbeat config (DC + Win10)
│   ├── filebeat/
│   │   └── filebeat.yml         # Filebeat config (Ubuntu victim)
│   └── elk/
│       └── logstash-pipeline.conf  # Logstash pipeline
├── playbooks/
│   ├── IR-001-brute-force.md
│   ├── IR-002-lateral-movement.md
│   ├── IR-003-credential-dumping.md
│   └── IR-004-malware-execution.md
├── scenarios/
│   └── README.md                # Attack scenarios index
└── docs/
    └── credentials.md           # 🔒 Lab credentials reference (NEVER commit real creds)
```

---

## ⚡ Quick Status

See [`STATUS.md`](./STATUS.md) for the full checklist.

---

## 🔗 Key Links (internal)

| Service | URL |
|---------|-----|
| Kibana | `https://172.16.0.4:5601` |
| Elasticsearch | `https://172.16.0.4:9200` |
| pfSense Web UI | `https://172.16.0.1` |

---

*Lab by [KuRo](https://github.com/KuRo0x)*
