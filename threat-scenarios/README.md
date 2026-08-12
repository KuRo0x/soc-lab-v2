# Threat Scenarios

Each subdirectory documents a complete attack scenario — from setup through execution, detection, and remediation. Scenarios map directly to MITRE ATT&CK techniques and corresponding Sigma rules.

## Index

| ID | Technique | MITRE | Status | Sigma Rule |
|----|-----------|-------|--------|------------|
| [INC-001](./INC-001-llmnr-poisoning/) | LLMNR/NBT-NS Poisoning | T1557.001 | 🔲 Pending | ⬜ TODO |
| [INC-002](./INC-002-asrep-roasting/) | AS-REP Roasting | T1558.004 | ✅ Complete | ✅ Done |
| [INC-003](./INC-003-kerberoasting/) | Kerberoasting | T1558.003 | 🔲 Pending | ⬜ TODO |
| [INC-004](./INC-004-pass-the-hash/) | Pass-the-Hash | T1550.002 | 🔲 Pending | ⬜ TODO |
| [INC-005](./INC-005-dcsync/) | DCSync | T1003.006 | 🔲 Pending | ⬜ TODO |
| [INC-006](./INC-006-c2-beacon/) | C2 over HTTP/S | T1071.001 | 🔲 Pending | ⬜ TODO |
| [INC-007](./INC-007-phishing-macro/) | Phishing → Macro Execution | T1566.001 | 🔲 Pending | ⬜ TODO |

## Scenario Structure

Each scenario folder follows this layout:
```
INC-XXX-name/
├── README.md     — Full attack + detection writeup
├── iocs.md       — Indicators of Compromise
└── evidence/     — Screenshots, ELK exports, pcaps
```

## Scenario Template

When starting a new scenario, copy from:
`playbooks/templates/scenario-template.md`
