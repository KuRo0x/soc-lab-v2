---
name: Detection Gap
about: Report a TTP that is not currently covered by a Sigma rule or alert
title: 'GAP: [TTP Name] — T[XXXX.XXX]'
labels: detection-gap, sigma
assignees: ''
---

## Gap Summary
- **MITRE ATT&CK:** T[XXX.XXX] — [Technique Name]
- **Tactic:** [e.g. Credential Access]
- **Priority:** High / Medium / Low

## Why This Matters
<!-- What attack does this enable? What would we miss? -->

## Proposed Detection Logic
```
<!-- ELK/KQL or Sigma logic draft -->
```

## Data Sources Required
- [ ] Windows Security Event Log
- [ ] Sysmon
- [ ] PowerShell logging
- [ ] Suricata/network
- [ ] Other:

## Acceptance Criteria
- [ ] Sigma rule created in `detection/sigma/`
- [ ] Rule validated against a real lab event
- [ ] False positive analysis documented
- [ ] Coverage matrix updated
