# SOC Playbooks

This directory contains operational playbooks for the soc-lab-v2 environment — incident response procedures, triage guides, hardening controls, and reusable templates.

## Structure

```
playbooks/
├── ir-process.md           — End-to-end IR workflow (Triage → Contain → Eradicate → Recover)
├── lab-hardening.md        — Full lab hardening guide (all components)
├── triage/
│   ├── kerberos-attacks.md     — Triage guide for INC-002, INC-003
│   ├── lateral-movement.md     — Triage guide for INC-004, INC-005
│   └── credential-access.md    — General credential attack triage
└── templates/
    ├── scenario-template.md    — Blank template for new INC scenarios
    └── incident-report-template.md
```
