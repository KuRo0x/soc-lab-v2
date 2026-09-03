# INC-001 — Detection Logic

## Detection Sources

| Source | What it Catches |
|--------|-----------------|
| Winlogbeat (DC) | EID 4662 — AD object ACL write (WRITE_DAC + Write Property) triggered by relay |
| Winlogbeat (DC) | EID 4624 LogonType 3 — network logon from unexpected source |
| Suricata (pfSense LAN) | LLMNR/NBT-NS/MDNS poisoning traffic — multicast responses from attacker |

---

## Sigma Rule — NTLM Relay → LDAP ACL Write (Winlogbeat)

See `detection/sigma/T1557.001-llmnr-ntlm-relay.yml`

Converted Lucene query (sigma-cli 3.1.0, ecs_windows pipeline):

```lucene
winlog.channel:Security AND (event.code:4662 AND winlog.event_data.ObjectServer:DS AND (winlog.event_data.AccessMask:(*0x20* OR *0x40000*)))
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
- [x] Kibana detection rule created and fired — `NTLM Relay — Suspicious AD Object ACL Write (T1557.001)` — High, Risk 73 — 2 alerts confirmed (2026-09-03)
- [ ] Suricata LLMNR alert confirmed in `suricata-*` index

---

## Evidence Screenshots

- `evidence/kibana-4662-ldap-relay-acl-write.png` — Kibana table view, both 4662 events
