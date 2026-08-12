# ATT&CK Detection Coverage Matrix

> Last updated: 2026-08-12
> Lab: soc-lab-v2 | Domain: soc.lab

## Coverage Summary

| INC | MITRE ID | Technique | Tactic | Sigma Rule | ELK Alert | Status |
|-----|----------|-----------|--------|------------|-----------|--------|
| INC-001 | T1557.001 | LLMNR/NBT-NS Poisoning | Credential Access | ⬜ TODO | ⬜ TODO | 🔲 Pending |
| INC-002 | T1558.004 | AS-REP Roasting | Credential Access | ✅ Done | ⬜ TODO | ✅ Complete |
| INC-003 | T1558.003 | Kerberoasting | Credential Access | ⬜ TODO | ⬜ TODO | 🔲 Pending |
| INC-004 | T1550.002 | Pass-the-Hash | Lateral Movement | ⬜ TODO | ⬜ TODO | 🔲 Pending |
| INC-005 | T1003.006 | DCSync | Credential Access | ⬜ TODO | ⬜ TODO | 🔲 Pending |
| INC-006 | T1071.001 | C2 over HTTP/S | Command & Control | ⬜ TODO | ⬜ TODO | 🔲 Pending |
| INC-007 | T1566.001 | Phishing → Macro | Initial Access | ⬜ TODO | ⬜ TODO | 🔲 Pending |

## Data Sources Available

| Source | Agent | Index | Status |
|--------|-------|-------|--------|
| Windows Security Events | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Active |
| Sysmon | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Active |
| PowerShell Logging | Winlogbeat 8.17.0 | `winlogbeat-*` | ✅ Active |
| Linux Auditd | Filebeat | `filebeat-*` | ⬜ Output fix needed |
| Network/IDS (Suricata) | — | — | ⬜ Not deployed yet |

## Key Event IDs Monitored

| Event ID | Description | Scenario |
|----------|-------------|----------|
| 4768 | Kerberos TGT Request | INC-002 AS-REP Roasting |
| 4769 | Kerberos Service Ticket Request | INC-003 Kerberoasting |
| 4624 | Logon Success | General |
| 4625 | Logon Failure | Brute Force |
| 4662 | Object Access (AD) | INC-005 DCSync |
| 4776 | NTLM Auth | INC-004 Pass-the-Hash |
| 7045 | New Service Installed | Persistence |
| 1 | Sysmon: Process Create | General |
| 3 | Sysmon: Network Connect | C2 / Lateral Movement |
| 11 | Sysmon: File Create | Malware Drop |
