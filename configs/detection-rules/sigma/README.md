# Sigma Detection Rules

Vendor-neutral rules in Sigma format. Versioned in git — treated like code.

## Naming Convention
`<inc-id>-<short-description>.yml`
Example: `inc001-llmnr-poisoning.yml`

## Convert to KQL
```bash
pip install sigma-cli
sigma convert -t kibana-ndjson inc001-llmnr-poisoning.yml
```

## Rules Index

| File | Technique | Status |
|------|-----------|--------|
| inc001-llmnr-poisoning.yml | T1557.001 | Draft |
| inc002-asrep-roasting.yml | T1558.004 | Draft |
