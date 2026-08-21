# Scripts

This directory contains automation scripts for the soc-lab-v2 environment.

> ⚠️ **All subfolders are currently empty scaffolding.** Scripts will be added as each area matures. Do not treat an empty folder as a completed item.

## Subfolders

| Folder | Purpose | Status |
|--------|---------|--------|
| `setup/` | Initial VM configuration and provisioning scripts | 🔲 Planned |
| `deployment/` | Agent deployment (Winlogbeat, Sysmon, Filebeat) | 🔲 Planned |
| `detection/` | Detection rule deployment / Sigma-to-ELK conversion scripts | 🔲 Planned |
| `log-parsing/` | Logstash pipeline helpers and parsing tests | 🔲 Planned |
| `validation/` | Environment health checks (pipeline alive, index present, agent running) | 🔲 Planned |

## Conventions (when scripts are added)
- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail`
- Python scripts: 3.10+, dependencies listed in a local `requirements.txt`
- Every script must include a header comment: purpose, usage, target host
