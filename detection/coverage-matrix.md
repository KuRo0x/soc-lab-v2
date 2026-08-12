# ATT&CK Detection Coverage Matrix

> Last updated: 2026-08-12
> Lab: soc-lab-v2 | Domain: soc.lab
> Only lists scenarios that have been **executed and verified** in the lab.

---

## ✅ Active Coverage

| INC | MITRE ID | Technique | Tactic | Sigma Rule | ELK Verified | Status |
|-----|----------|-----------|--------|------------|--------------|--------|
| INC-002 | T1558.004 | AS-REP Roasting | Credential Access | ✅ [`T1558.004-asrep-roasting.yml`](./sigma/T1558.004-asrep-roasting.yml) | ✅ Event 4768 confirmed | ✅ Complete |

---

## 🔲 Planned (Not Yet Executed)

| INC | MITRE ID | Technique | Tactic |
|-----|----------|-----------|--------|
| INC-001 | T1557.001 | LLMNR/NBT-NS Poisoning | Credential Access |
| INC-003 | T1558.003 | Kerberoasting | Credential Access |
| INC-004 | T1550.002 | Pass-the-Hash | Lateral Movement |
| INC-005 | T1003.006 | DCSync | Credential Access |
| INC-006 | T1071.001 | C2 over HTTP/S | Command & Control |
| INC-007 | T1566.001 | Phishing → Macro | Initial Access |

> Sigma rules and ELK alerts for planned scenarios will be added **after** each scenario is executed and detection is verified live.

---

## Data Sources Active

| Source | Agent | Index | Status |
|--------|-------|-------|--------|
| Windows Security Events | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Live |
| Sysmon | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Live |
| PowerShell Logging | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Live |
| Linux Auditd/Filebeat | Filebeat | `filebeat-*` | ⚠️ Output config needs fix |
| Suricata/Network IDS | — | — | ❌ Not deployed |

---

## Key Event IDs Monitored (Confirmed Working)

| Event ID | Description | Confirmed In Lab |
|----------|-------------|------------------|
| 4768 | Kerberos TGT Request | ✅ INC-002 |

> Additional event IDs will be confirmed and added as each scenario runs.
