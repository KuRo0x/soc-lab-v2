# INC-003 — Detection Logic

> **Status:** ✅ Validated in lab (2026-08-20)

---

## Key Events

| Event ID | Description | Detection Signal |
|----------|-------------|------------------|
| **4769** | Kerberos TGS Request (TGS-REP) | `TicketEncryptionType: 0x17` (RC4) + non-machine account |

---

## KQL Query (Kibana)

```kql
event.code: "4769"
AND winlog.event_data.TicketEncryptionType: "0x17"
AND NOT winlog.event_data.ServiceName: "*$"
```

> The `NOT ServiceName: *$` filter excludes machine account TGS requests, reducing noise from normal Kerberos traffic. All service accounts end without `$`, all computer accounts end with `$`.

**Validated result:** Confirmed in index `winlogbeat-2026.08.20`, record `52849`. Event visible in Kibana within ~17s of attack execution.

---

## Sigma Rule

See [`detection/sigma/T1558.003-kerberoasting.yml`](../../detection/sigma/T1558.003-kerberoasting.yml)

```yaml
title: Kerberoasting — TGS Request with RC4 Encryption
id: inc003-kerberoasting
status: experimental
description: Detects Kerberoasting via TGS requests using RC4 (etype 0x17) for non-machine accounts
author: KuRo
date: 2026-08-20
tags:
  - attack.credential_access
  - attack.t1558.003
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4769
    TicketEncryptionType: '0x17'
  filter_machine_accounts:
    ServiceName|endswith: '$'
  condition: selection and not filter_machine_accounts
falsepositives:
  - Legacy applications requiring RC4
level: high
```

---

## Validation Checklist

- [x] DC Security logs forwarded via Winlogbeat — confirmed, index `winlogbeat-2026.08.20`
- [x] Scenario executed and detection validated — EID 4769, `EncType: 0x17`, record `52849`
- [x] Kibana alert reviewed — RC4 TGS request from Kali IP confirmed
- [ ] Evidence screenshots — TODO: add to `evidence/` folder

---

## False Positives

- Legacy applications that explicitly request RC4 tickets (document all such apps)
- Silver ticket generation in pen test contexts

> In production: RC4 should be globally disabled via GPO (`Network security: Configure encryption types allowed for Kerberos`). If it is, this alert becomes noise-free.
