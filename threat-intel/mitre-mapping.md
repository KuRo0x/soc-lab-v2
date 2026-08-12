# MITRE ATT&CK Mapping

> Framework: MITRE ATT&CK Enterprise v15
> Lab: soc-lab-v2 | Domain: soc.lab
> **Only techniques that have been executed and detected in this lab are marked complete.**

---

## ✅ Verified in Lab

| Tactic | Technique ID | Technique Name | Lab Scenario | Date |
|--------|-------------|----------------|--------------|------|
| Credential Access | T1558.004 | AS-REP Roasting | INC-002 | 2026-08-12 |

### T1558.004 — AS-REP Roasting ✅
- **Tactic:** Credential Access
- **Platform:** Windows / Active Directory
- **Tool used:** Impacket `GetNPUsers.py` + Hashcat `-m 18200`
- **Detection:** Event ID 4768, `TicketEncryptionType: 0x17`, `PreAuthType: 0`
- **Sigma Rule:** [`detection/sigma/T1558.004-asrep-roasting.yml`](../detection/sigma/T1558.004-asrep-roasting.yml)
- **Writeup:** [`threat-scenarios/INC-002-asrep-roasting/`](../threat-scenarios/INC-002-asrep-roasting/README.md)
- **Mitigation:** Enforce Kerberos pre-authentication on all accounts; disable RC4 (etype 0x17) via GPO; use gMSA for service accounts

---

## 🔲 Planned (Not Yet Executed)

| Tactic | Technique ID | Technique Name | Scenario |
|--------|-------------|----------------|----------|
| Credential Access | T1557.001 | LLMNR/NBT-NS Poisoning | INC-001 |
| Credential Access | T1558.003 | Kerberoasting | INC-003 |
| Credential Access | T1003.006 | DCSync | INC-005 |
| Lateral Movement | T1550.002 | Pass-the-Hash | INC-004 |
| Command & Control | T1071.001 | Web Protocols (C2) | INC-006 |
| Initial Access | T1566.001 | Phishing: Spearphishing Attachment | INC-007 |

> Technique details, detection logic, and Sigma rules will be documented here as each scenario is executed.
