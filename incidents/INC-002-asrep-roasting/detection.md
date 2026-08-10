# INC-002 — Detection Logic

## Key Event
- **Windows Security EID 4768** — Kerberos TGT request with `PreAuthType = 0` (no pre-auth)

## Sigma Rule

```yaml
title: AS-REP Roasting — Kerberos Pre-Auth Disabled
id: inc002-asrep-roasting
status: experimental
description: Detects AS-REP Roasting via TGT requests where pre-authentication is disabled
author: KuRo
date: 2026-08-11
tags:
  - attack.credential_access
  - attack.t1558.004
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4768
    PreAuthType: '0'
    Status: '0x0'
falsepositives:
  - Legacy service accounts with pre-auth disabled
level: high
```

## KQL Query (Kibana)

```kql
event.code:4768 AND winlog.event_data.PreAuthType:0
```

## Validation
- [ ] Ensure DC Security logs forwarded via Winlogbeat
- [ ] Execute scenario and validate detection
- [ ] Create Kibana alert
