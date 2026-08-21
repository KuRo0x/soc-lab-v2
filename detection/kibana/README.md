# Kibana Detection Rules

This folder will hold exported Kibana detection/alert rules as `.ndjson` files.

> ⚠️ **TODO:** Export verified rules from Kibana and commit them here.

## How to Export

1. Open Kibana → **Stack Management** → **Security** → **Rules**
2. Select the rules you want to export
3. Click **Bulk actions** → **Export**
4. Save the `.ndjson` file to this folder
5. Commit with message: `feat: export kibana rule <rule-name>`

## How to Import (on a new/rebuilt ELK)

```bash
curl -X POST "https://localhost:5601/api/detection_engine/rules/_import" \
  -H "kbn-xsrf: true" \
  -u elastic:<password> \
  --form file=@./rule-name.ndjson
```

## Rules Pending Export

| Rule | MITRE | Verified In Lab | Exported |
|------|-------|-----------------|----------|
| AS-REP Roasting — EID 4768 + EncType 0x17 + PreAuth 0 | T1558.004 | ✅ 2026-08-12 | 🔲 TODO |
| Kerberoasting — EID 4769 + EncType 0x17 | T1558.003 | ✅ 2026-08-20 | 🔲 TODO |
