# Threat Scenarios

Each subdirectory documents a complete attack scenario — setup, execution, detection, and remediation.
All scenarios map to MITRE ATT&CK techniques with corresponding Sigma rules.

> **Policy:** A scenario folder only exists here once it has been **fully executed in the lab**. No stubs, no placeholders.

---

## Completed Scenarios

| ID | Technique | MITRE | Date | Sigma Rule |
|----|-----------|-------|------|------------|
| [INC-002](./INC-002-asrep-roasting/) | AS-REP Roasting | T1558.004 | 2026-08-12 | ✅ [`T1558.004-asrep-roasting.yml`](../detection/sigma/T1558.004-asrep-roasting.yml) |

---

## Planned Scenarios

| ID | Technique | MITRE |
|----|-----------|-------|
| INC-001 | LLMNR/NBT-NS Poisoning + NTLM Relay | T1557.001 |
| INC-003 | Kerberoasting | T1558.003 |
| INC-004 | Pass-the-Hash | T1550.002 |
| INC-005 | DCSync | T1003.006 |
| INC-006 | C2 Beacon | T1071.001 |
| INC-007 | Phishing → Macro Execution | T1566.001 |

> Folders for planned scenarios will be created when they are executed.

---

## Scenario Structure

```
INC-XXX-name/
├── README.md     — Full attack + detection writeup
├── iocs.md       — Indicators of Compromise
└── evidence/     — Screenshots, ELK exports
```

Template: [`playbooks/templates/scenario-template.md`](../playbooks/templates/scenario-template.md)
