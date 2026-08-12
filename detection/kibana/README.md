# Kibana Saved Searches & Alerts

This directory stores exported Kibana saved searches, dashboards, and alert configurations.

## Export Instructions

1. In Kibana → Stack Management → Saved Objects
2. Select the objects you want to export
3. Click Export → include related objects
4. Save the `.ndjson` file here

## Import Instructions

```bash
# Via Kibana API
curl -X POST "https://172.16.0.4:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  --form file=@detection/kibana/your-export.ndjson
```

## Available Exports

| File | Contents | Scenario |
|------|----------|----------|
| *(none yet)* | — | — |

> Add Kibana exports here as scenarios are completed.
