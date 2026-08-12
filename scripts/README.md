# Scripts

Automation scripts organized by function. All scripts are documented — read the header comments before running.

## Structure

```
scripts/
├── setup/          — Agent deployment and initial configuration
├── detection/      — AD auditing and security posture checks
├── validation/     — Verify lab pipeline health (ELK, agents, indices)
└── attack-sim/     — Documented attack runners for lab scenarios (READ BEFORE RUNNING)
```

## ⚠️ Warning

Scripts in `attack-sim/` are for **lab use only** against systems you own and control. Never run against production or unauthorized systems.
