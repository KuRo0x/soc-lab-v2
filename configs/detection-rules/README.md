# Detection Rules

This directory holds custom Elasticsearch / Kibana detection rules exported as NDJSON.

## Files

| File | Description | MITRE |
|------|-------------|-------|
| _(none yet)_ | Export from Kibana: Stack Management > Rules | — |

## How to Export

```bash
# From Kibana UI:
# Stack Management > Alerts and Insights > Rules
# Select all custom rules → Export
# Save as detection-rules.ndjson in this directory
```

## How to Import

```bash
# Stack Management > Saved Objects > Import
# Select detection-rules.ndjson
```

## TODO
- [ ] Export INC-002 ASREPRoasting Kibana detection rule
- [ ] Export INC-001 LLMNR detection rule (once built)
