# MITRE ATT&CK Mapping

> Framework: MITRE ATT&CK Enterprise v15
> Lab: soc-lab-v2 | Domain: soc.lab

## Technique Coverage

| Tactic | Technique ID | Technique Name | Lab Scenario | Status |
|--------|-------------|----------------|--------------|--------|
| Initial Access | T1566.001 | Phishing: Spearphishing Attachment | INC-007 | 🔲 Pending |
| Credential Access | T1557.001 | LLMNR/NBT-NS Poisoning | INC-001 | 🔲 Pending |
| Credential Access | T1558.004 | AS-REP Roasting | INC-002 | ✅ Complete |
| Credential Access | T1558.003 | Kerberoasting | INC-003 | 🔲 Pending |
| Credential Access | T1003.006 | DCSync | INC-005 | 🔲 Pending |
| Lateral Movement | T1550.002 | Pass-the-Hash | INC-004 | 🔲 Pending |
| Command & Control | T1071.001 | Web Protocols (C2) | INC-006 | 🔲 Pending |

## ATT&CK Navigator Layer

To visualize coverage in the ATT&CK Navigator:
1. Go to https://mitre-attack.github.io/attack-navigator/
2. Create New Layer → Enterprise
3. Highlight techniques above manually or import a layer JSON

> TODO: Export and commit ATT&CK Navigator layer JSON as `threat-intel/attack-navigator-layer.json`

## Technique Details

### T1558.004 — AS-REP Roasting ✅
- **Tactic:** Credential Access
- **Platforms:** Windows
- **Data Sources:** Windows Security Event Log (4768)
- **Detection:** Event ID 4768 with TicketEncryptionType 0x17 and PreAuthType 0
- **Mitigation:** M1041 — Encrypt Sensitive Information; enforce AES-only Kerberos
- **Lab Reference:** [INC-002](../threat-scenarios/INC-002-asrep-roasting/README.md)

### T1558.003 — Kerberoasting 🔲
- **Tactic:** Credential Access
- **Platforms:** Windows
- **Data Sources:** Windows Security Event Log (4769)
- **Detection:** Event ID 4769 with TicketEncryptionType 0x17 from non-service hosts
- **Mitigation:** Use gMSA (Group Managed Service Accounts); enforce strong SPN passwords
- **Lab Reference:** [INC-003](../threat-scenarios/INC-003-kerberoasting/README.md)
