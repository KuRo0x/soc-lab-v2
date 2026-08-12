# Detection Engineering

This directory contains all detection content for soc-lab-v2 — Sigma rules, Kibana exports, and the ATT&CK coverage matrix.

## Structure

```
detection/
├── sigma/          — One Sigma rule per TTP, named by ATT&CK ID
├── kibana/         — Exported Kibana saved searches and alert configs
└── coverage-matrix.md — ATT&CK coverage at a glance
```

## Sigma Rule Naming Convention

```
T[technique-id]-[short-name].yml

Examples:
  T1557.001-llmnr-poisoning.yml
  T1558.004-asrep-roasting.yml
  T1558.003-kerberoasting.yml
```

## Testing a Rule

Validate Sigma rules against real events using `sigma-cli`:

```bash
# Install
pip install sigma-cli

# Convert to ECS/Kibana query
sigma convert -t lucene -p ecs_windows detection/sigma/T1558.004-asrep-roasting.yml
```

## Coverage Matrix

See [coverage-matrix.md](./coverage-matrix.md)
