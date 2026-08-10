# INC-001 — Detection Logic

## Sigma Rule

```yaml
title: LLMNR/NBT-NS Poisoning — Suspicious UDP 5355/137 Traffic
id: inc001-llmnr-poisoning
status: experimental
description: Detects LLMNR (UDP 5355) or NBT-NS (UDP 137) traffic indicating potential poisoning
author: KuRo
date: 2026-08-11
references:
  - https://attack.mitre.org/techniques/T1557/001/
tags:
  - attack.credential_access
  - attack.t1557.001
logsource:
  category: network_connection
  product: windows
detection:
  selection:
    EventID: 3
    DestinationPort:
      - 5355
      - 137
  condition: selection
falsepositives:
  - Legitimate LLMNR traffic where LLMNR is enabled by policy
level: medium
```

## KQL Query (Kibana)

```kql
event.code:3 AND (destination.port:5355 OR destination.port:137)
```

## What to Look For
- Sysmon EID 3 from victim to attacker IP on port 5355 or 137
- Multiple connections in short time window
- Destination IP matches attacker (172.16.0.11)

## Validation
- [ ] Execute scenario and validate rule fires
- [ ] Tune false positive filter
- [ ] Create Kibana alert with threshold
