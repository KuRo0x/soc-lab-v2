# INC-001 — Detection Logic

## Detection Sources

| Source | What it Catches |
|--------|-----------------|
| Winlogbeat (DC) | EID 4662 — AD object ACL write (WRITE_DAC + Write Property) triggered by relay |
| Winlogbeat (DC) | EID 4624 LogonType 3 — network logon from unexpected source |
| Suricata (pfSense LAN) | LLMNR/NBT-NS/MDNS poisoning traffic — multicast responses from attacker |

---

## KQL Query — Kibana (Detection Evidence)

```kql
event.code: "4662"
AND winlog.event_data.SubjectUserName: "Administrator"
AND winlog.event_data.ObjectServer: "DS"
AND _index: "winlogbeat-2026.09.03"
```

**Result:** 2 events — records 71400 and 71402 — fired at 11:31:12Z during relay session.

---

## Sigma Rule

See [`detection/sigma/T1557.001-llmnr-ntlm-relay.yml`](../../detection/sigma/T1557.001-llmnr-ntlm-relay.yml)

```yaml
title: NTLM Relay - Suspicious AD Object ACL Write via LDAP
id: f3a1e2b0-2c5d-4f9a-8e7b-1d4c6a7f8901
status: experimental
description: >
  Detects two EID 4662 Directory Service Access events — WRITE_DAC (0x40000)
  and Write Property (0x20) — fired against an AD object by a domain admin account.
  This pattern is consistent with ntlmrelayx LDAP relay escalation (T1557.001)
  granting Replication-Get-Changes-All rights to the relayed account.
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
    EventID: 4662
    ObjectServer: DS
    AccessMask|contains:
      - '0x20'
      - '0x40000'
  condition: selection
falsepositives:
  - Legitimate AD administrative operations during maintenance windows
  - Group Policy or AD replication tasks
level: high
```

Converted Lucene query (sigma-cli 3.1.0, ecs_windows pipeline):

```lucene
winlog.channel:Security AND (event.code:4662 AND winlog.event_data.ObjectServer:DS AND (winlog.event_data.AccessMask:(*0x20* OR *0x40000*)))
```

---

## What to Look For

- **EID 4662, ObjectServer: DS** — any write to AD object outside scheduled admin window
- **AccessMask 0x40000 (WRITE_DAC)** — attacker modifying DACL on domain object
- **AccessMask 0x20 (Write Property)** — attacker writing replication rights
- Two 4662 events firing within milliseconds of each other = relay tool signature
- Correlate with EID 4624 LogonType 3 NTLM from unexpected source IP

---

## Observed Evidence (2026-09-03)

| Record | Event ID | Access | AccessMask | Timestamp (UTC) |
|--------|----------|--------|------------|----------------|
| 71400 | 4662 | WRITE_DAC | 0x40000 | 11:31:12.039Z |
| 71402 | 4662 | Write Property | 0x20 | 11:31:12.079Z |

Both events: `SOC\Administrator` on `SOC-Lab-DC.soc.lab` — index `winlogbeat-2026.09.03`

---

## Validation

- [x] Sigma rule tested against real execution
- [x] Events confirmed in Kibana — 2 EID 4662 records
- [x] Kibana detection rule created and fired — `NTLM Relay — Suspicious AD Object ACL Write (T1557.001)` — High, Risk 73 — 2 alerts confirmed (2026-09-03)
- [ ] Suricata LLMNR alert confirmed in `suricata-*` index

---

## Evidence Screenshots

- `evidence/kibana-4662-ldap-relay-acl-write.png` — Kibana table view, both 4662 events
