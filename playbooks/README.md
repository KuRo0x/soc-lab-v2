# SOC Playbooks

This directory contains operational playbooks for the soc-lab-v2 environment — incident response procedures, triage guides, hardening controls, and reusable templates.

## Incident Response Playbooks

| Playbook | Coverage |
|----------|----------|
| [IR-001-brute-force.md](./IR-001-brute-force.md) | Brute force / password spraying |
| [IR-002-lateral-movement.md](./IR-002-lateral-movement.md) | Lateral movement detection & response |
| [IR-003-credential-dumping.md](./IR-003-credential-dumping.md) | LSASS / DCSync / secretsdump |
| [IR-004-malware-execution.md](./IR-004-malware-execution.md) | Malware execution & process injection |
| [IR-005-kerberos-attacks.md](./IR-005-kerberos-attacks.md) | AS-REP Roasting (INC-002) + Kerberoasting (INC-003) |

## Structure

```
playbooks/
├── IR-001-brute-force.md
├── IR-002-lateral-movement.md
├── IR-003-credential-dumping.md
├── IR-004-malware-execution.md
├── IR-005-kerberos-attacks.md
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
