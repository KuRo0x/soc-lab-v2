# INC-005 — Detection Notes

> **Technique:** T1003.006 — DCSync  
> **Primary event:** EID 4662 (Windows Security Log — DC only)

---

## 📌 Key Detection Logic

DCSync is detected by monitoring for **EID 4662** on the Domain Controller where:
- A **non-DC account** (i.e. not a machine account ending in `$`) triggers AD replication
- The **Properties** field contains one of the DCSync GUIDs:
  - `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` — Replicating Directory Changes
  - `1131f6ad-9c07-11d1-f79f-00c04fc2dcd2` — Replicating Directory Changes All
  - `89e95b76-444d-4c62-991a-0facbeda640c` — Replicating Directory Changes In Filtered Set

---

## 🔎 KQL Query (Kibana)

```kql
event.code: "4662"
AND winlog.event_data.Properties: ("1131f6aa*" OR "1131f6ad*" OR "89e95b76*")
AND NOT winlog.event_data.SubjectUserName: (*$)
```

> Run this in Kibana → Discover against the `winlogbeat-*` index pattern.  
> Filter by time window of the attack to isolate relevant events.

---

## 🔎 Alternative: Search by Subject Account

```kql
event.code: "4662" AND winlog.event_data.SubjectUserName: "svc_asrep"
```

---

## 📊 Expected Results in Kibana

| Field | Expected Value |
|-------|----------------|
| `event.code` | 4662 |
| `winlog.event_data.SubjectUserName` | svc_asrep |
| `winlog.event_data.ObjectType` | %{19195a5b-...} (domainDNS) |
| `winlog.event_data.Properties` | Contains DCSync GUIDs |
| `winlog.computer_name` | SOC-Lab-DC |
| Source IP | 172.16.0.11 (Kali) |

---

## 📝 Sigma Rule

See [`detection/sigma/T1003.006-dcsync.yml`](../../detection/sigma/T1003.006-dcsync.yml)

---

## ⚠️ Audit Policy Requirement

EID 4662 requires **Directory Service Access** auditing to be enabled on the DC:

```
auditpol /get /subcategory:"Directory Service Access"
```

Expected: `Success and Failure` — if not set, run:

```
auditpol /set /subcategory:"Directory Service Access" /success:enable /failure:enable
```
