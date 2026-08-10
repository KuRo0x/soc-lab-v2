# INC-XXX — Detection Logic

## Sigma Rule

```yaml
title:
id:
status: experimental
description:
author: KuRo
date: YYYY-MM-DD
tags:
  - attack.<tactic>
  - attack.tXXXX
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID:
  condition: selection
falsepositives:
  -
level: medium
```

## KQL Query (Kibana)

```kql
# Paste query here
```

## What to Look For
- Key event IDs
- Field values indicating malicious activity
- Thresholds / timeframes

## Validation
- [ ] Tested against real execution
- [ ] False positive rate acceptable
- [ ] Kibana alert created
