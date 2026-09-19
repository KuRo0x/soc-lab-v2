# ATT&CK Detection Coverage Matrix

> Last updated: 2026-09-13
> Lab: soc-lab-v2 | Domain: soc.lab  
> Only lists scenarios that have been **executed and verified** in the lab.

---

## ✅ Active Coverage

| INC | MITRE ID | Technique | Tactic | Sigma Rule | ELK Verified | Canonical Write-up | Status |
|-----|----------|-----------|--------|------------|--------------|-------------------|--------|
| INC-001 | T1557.001 | LLMNR/NTLM Relay | Credential Access | ✅ [`T1557.001-llmnr-ntlm-relay.yml`](./sigma/T1557.001-llmnr-ntlm-relay.yml) | ✅ Event 4662 confirmed | [`incidents/INC-001-llmnr-ntlm-relay/`](../incidents/INC-001-llmnr-ntlm-relay/) | ✅ Complete |
| INC-002 | T1558.004 | AS-REP Roasting | Credential Access | ✅ [`T1558.004-asrep-roasting.yml`](./sigma/T1558.004-asrep-roasting.yml) | ✅ Event 4768 confirmed | [`incidents/INC-002-asrep-roasting/`](../incidents/INC-002-asrep-roasting/) | ✅ Complete |
| INC-003 | T1558.003 | Kerberoasting | Credential Access | ✅ [`T1558.003-kerberoasting.yml`](./sigma/T1558.003-kerberoasting.yml) | ✅ Event 4769 confirmed | [`incidents/INC-003-kerberoasting/`](../incidents/INC-003-kerberoasting/) | ✅ Complete |
| INC-004 | T1550.002 | Pass-the-Hash | Lateral Movement | ✅ [`T1550.002-pass-the-hash.yml`](./sigma/T1550.002-pass-the-hash.yml) | ✅ Event 4624 confirmed | [`incidents/INC-004-pass-the-hash/`](../incidents/INC-004-pass-the-hash/) | ✅ Complete |
| INC-005 | T1003.006 | DCSync | Credential Access | ✅ [`T1003.006-dcsync.yml`](./sigma/T1003.006-dcsync.yml) | ✅ Event 4662 confirmed | [`incidents/INC-005-dcsync/`](../incidents/INC-005-dcsync/) | ✅ Complete |

---

## 🔲 Planned (Not Yet Executed)

| INC | MITRE ID | Technique | Tactic |
|-----|----------|-----------|--------|
| INC-006 | T1071.001 | C2 over HTTP/S | Command & Control |
| INC-007 | T1566.001 | Phishing → Macro | Initial Access |

> Sigma rules and ELK alerts for planned scenarios will be added **after** each scenario is executed and detection is verified live.

---

## Kibana Alert Rules

> One verified Kibana rule export is committed in `detection/kibana/`. Export the remaining verified rules as they are finalized.

---

## Data Sources Active

| Source | Agent | Index | Status |
|--------|-------|-------|--------|
| Windows Security Events | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Live |
| Sysmon | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Live |
| PowerShell Logging | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Live |
| Linux Auditd/Filebeat | Filebeat 8.19.17 | `filebeat-*` | ✅ Live (Logstash output verified 2026-08-20) |
| Suricata/Network IDS | Logstash 8.x | `suricata-*` | ✅ Live via pfSense EVE JSON |

---

## Key Event IDs Monitored (Confirmed Working)

| Event ID | Description | Confirmed In Lab |
|----------|-------------|------------------|
| 4768 | Kerberos TGT Request (AS-REQ/AS-REP) | ✅ INC-002 |
| 4769 | Kerberos TGS Request (TGS-REP) | ✅ INC-003 |
| 4624 | Network logon | ✅ INC-004 |
| 4662 | Directory Service Access | ✅ INC-001, INC-005 |

> Additional event IDs will be confirmed and added as each scenario runs.
