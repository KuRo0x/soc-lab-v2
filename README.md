# 🛡️ SOC Home Lab v2

> **Advanced, enterprise-grade SOC lab built for detection engineering, threat hunting, incident response, and malware analysis — not a toy lab.**

---

## Summary

This lab simulates a small Active Directory enterprise environment with a full ELK-based SIEM, network firewall, attacker infrastructure, and an isolated malware analysis workstation. Every incident documented here follows a consistent professional template: attacker perspective, MITRE ATT&CK mapping, detection logic (actual Sigma rules and SIEM queries), sanitized evidence, and an honest gaps/lessons section.

What separates this from a basic home lab:
- Detection content is **versioned and treated like code** (Sysmon config, Sigma rules, Logstash pipelines — all in git)
- Every incident maps explicitly to **MITRE ATT&CK tactics and techniques**
- A documented **threat model** drives which scenarios are built — not a random list
- **Gaps and limitations are acknowledged** — engineering maturity means knowing what you don't catch
- Clean git history with meaningful commits

---

## Architecture

```
                        [Internet]
                            |
                     [pfSense FW]
                      172.16.0.1
                            |
         ┌──────────────────┼──────────────────┐
         |                  |                  |
    [ELK SIEM]          [DC / AD]         [Kali Linux]
    172.16.0.4          172.16.0.5         172.16.0.11
    (Ubuntu 22.04)   (Win Server 2019)    (Attacker)
         |
    ┌────┴────┐
    |         |
[Win10]  [Ubuntu]
172.16.0.10  172.16.0.20
(Victim)  (Victim)

                    [FLARE-VM] ── isolated ──▶ pfSense BLOCK rule
                    172.16.0.30
                    (Malware Analysis)
```

Full diagram: [`docs/architecture.md`](./docs/architecture.md)

---

## Tech Stack

| Tool | Purpose | Version / Notes |
|------|---------|----------------|
| pfSense | Firewall, gateway, network segmentation | pfSense CE |
| Elasticsearch | Log storage and search | 8.x |
| Kibana | SIEM UI, dashboards, alerting | 8.x |
| Logstash | Log ingestion pipeline | 8.x |
| Sysmon | Host-based telemetry (Windows) | sysmon-modular v4.90 (Olaf Hartong) |
| Winlogbeat | Windows log shipping | 8.x |
| Filebeat | Linux log shipping | 8.x |
| Sigma | Vendor-neutral detection rules | — |
| Suricata | Network IDS/IPS | TODO |
| FLARE-VM | Malware analysis workstation | Isolated, no telemetry |
| Active Directory | Target enterprise environment | soc.lab domain |
| Kali Linux | Attacker simulation | Rolling |

---

## Incident Index

| ID | Name | MITRE Tactic | Technique | Status |
|----|------|-------------|-----------|--------|
| INC-001 | LLMNR Poisoning + NTLM Relay | Credential Access | T1557.001 | 🔲 TODO |
| INC-002 | AS-REP Roasting | Credential Access | T1558.004 | 🔲 TODO |
| INC-003 | Kerberoasting | Credential Access | T1558.003 | 🔲 TODO |
| INC-004 | Pass-the-Hash Lateral Movement | Lateral Movement | T1550.002 | 🔲 TODO |
| INC-005 | DCSync Attack | Credential Access | T1003.006 | 🔲 TODO |
| INC-006 | Malware Detonation + C2 Beacon | Execution / C2 | T1204, T1071 | 🔲 TODO |
| INC-007 | Phishing → Macro → PowerShell | Initial Access | T1566.001, T1059.005 | 🔲 TODO |

---

## Skills Demonstrated

| Competency | How It Shows Up |
|------------|----------------|
| Detection Engineering | Sigma rules, Sysmon tuning, Kibana alerts |
| Threat Hunting | KQL/EQL queries, log correlation across hosts |
| SIEM Administration | ELK deployment, index management, pipeline config |
| AD Security | Domain attacks simulated and detected end-to-end |
| Incident Response | Per-incident timelines, containment steps, IOC extraction |
| Malware Analysis | FLARE-VM static + dynamic analysis workflow |
| Network Security | pfSense rules, segmentation, IDS (Suricata — TODO) |

---

## How to Reproduce

See [`docs/build-guide.md`](./docs/build-guide.md) for full step-by-step deployment.

---

## Status

See [`STATUS.md`](./STATUS.md) for what's verified, what's missing, and what needs investigation.

---

*Built by [KuRo](https://github.com/KuRo0x)*
