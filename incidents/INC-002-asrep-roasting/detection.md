# INC-002 — Detection Logic

> **Status:** ✅ Validated in lab (2026-08-12)

---

## Key Events

| Event ID | Description | Detection Signal |
|----------|-------------|------------------|
| **4768** | Kerberos TGT Request (AS-REQ/AS-REP) | `PreAuthType: 0` + `TicketEncryptionType: 0x17` |

---

## KQL Query (Kibana)

```kql
event.code: "4768"
AND winlog.event_data.TicketEncryptionType: "0x17"
AND winlog.event_data.PreAuthType: "0"
```

**Validated result:** 2 documents returned — both attack runs confirmed in index `winlogbeat-2026.08.12`.

---

## Sigma Rule

See [`detection/sigma/T1558.004-asrep-roasting.yml`](../../detection/sigma/T1558.004-asrep-roasting.yml)

```yaml
title: AS-REP Roasting — Kerberos Pre-Auth Disabled
id: inc002-asrep-roasting
status: experimental
description: Detects AS-REP Roasting via TGT requests where pre-authentication is disabled
author: KuRo
date: 2026-08-12
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

---

## Validation Checklist

- [x] DC Security logs forwarded via Winlogbeat — confirmed, index `winlogbeat-2026.08.12`
- [x] Scenario executed and detection validated — 2 events captured, both attack runs visible
- [x] Kibana alert reviewed — EID 4768 + EncType 0x17 + PreAuth 0 confirmed

---

## False Positives

- Legacy service accounts with pre-authentication intentionally disabled (document all such accounts)
- Pre-Windows 2000 compatibility mode accounts

> In a real environment: baseline all accounts with `DoesNotRequirePreAuth = true` before alerting, so only new/unexpected accounts trigger.
