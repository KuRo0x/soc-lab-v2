# INC-001 — Detection Logic

## Detection Sources

| Source | What it Catches |
|--------|-----------------|
| Suricata (pfSense LAN) | LLMNR/NBT-NS poisoning traffic, anomalous multicast responses |
| Winlogbeat (Win10 + DC) | EID 4625 (failed relay attempt), EID 4624 LogonType 3 (successful relay) |
| Winlogbeat (DC) | EID 4776 (NTLM credential validation), EID 4624 unexpected NTLM source |

---

## Sigma Rule — NTLM Relay Lateral Movement (Winlogbeat)

```yaml
title: Suspicious NTLM Lateral Movement — Unexpected Source
id: b3e1f2a0-1c4d-4e8b-9f7a-2d3c5e6f7890
status: experimental
description: Detects NTLM network logon (LogonType 3) originating from an unexpected
  internal host — indicative of NTLM relay attack (T1557.001)
author: KuRo
date: 2026-09-03
tags:
  - attack.credential_access
  - attack.lateral_movement
  - attack.t1557.001
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4624
    LogonType: 3
    AuthenticationPackageName: NTLM
  filter_legitimate:
    IpAddress|startswith:
      - '172.16.0.5'   # DC — expected NTLM source
  condition: selection and not filter_legitimate
falsepositives:
  - Legacy applications using NTLM authentication
  - Print servers / file shares using NTLM
level: high
```

---

## KQL Query — Kibana (Winlogbeat)

```kql
event.code: "4624"
AND winlog.event_data.LogonType: "3"
AND winlog.event_data.AuthenticationPackageName: "NTLM"
AND NOT winlog.event_data.IpAddress: "172.16.0.5"
```

---

## KQL Query — Kibana (Suricata)

```kql
event.dataset: "suricata.eve"
AND (suricata.eve.alert.signature: *LLMNR* OR suricata.eve.alert.signature: *NBNS*)
```

---

## What to Look For

- **EID 4624, LogonType 3, NTLM** from a source that is not the DC — relay success
- **EID 4625, LogonType 3, NTLM** from unexpected source — relay attempt/failure
- **EID 4776** — NTLM credential validation spike from unexpected workstation
- **Suricata LLMNR alerts** — multicast poisoning traffic on LAN
- Responder generates high-volume LLMNR/NBT-NS multicast responses in a short window

---

## Validation

- [ ] Sigma rule tested against real execution
- [ ] False positive rate acceptable
- [ ] Kibana detection rule created and fired
- [ ] Suricata alert confirmed in `suricata-*` index
