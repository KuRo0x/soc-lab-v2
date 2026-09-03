# INC-001 — Detection Logic

## Detection Sources

| Source | What it Catches |
|--------|-----------------|
| Winlogbeat (DC) | EID 4662 — AD object ACL write (WRITE_DAC + Write Property) triggered by relay |
| Winlogbeat (DC) | EID 4624 LogonType 3 — network logon from unexpected source |
| Suricata (pfSense LAN) | LLMNR/NBT-NS/MDNS poisoning traffic — multicast responses from attacker |

---

## Sigma Rule — NTLM Relay → LDAP ACL Write (Winlogbeat)

```yaml
title: Suspicious AD Object ACL Write — Possible NTLM Relay via LDAP
id: b3e1f2a0-1c4d-4e8b-9f7a-2d3c5e6f7890
status: experimental
description: Detects AD directory service object access with Write Property or WRITE_DAC
  operations from a domain admin account — indicative of NTLM relay escalation via LDAP
  (T1557.001). Two EID 4662 events fired 40ms apart during confirmed relay session.
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
  - Legitimate AD administrative operations
  - Group Policy updates
level: high
```

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
- [ ] Kibana detection rule created and fired
- [ ] Suricata LLMNR alert confirmed in `suricata-*` index

---

## Evidence Screenshots

- `evidence/kibana-4662-ldap-relay-acl-write.png` — Kibana table view, both 4662 events
