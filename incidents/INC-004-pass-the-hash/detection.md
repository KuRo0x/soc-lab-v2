# INC-004 — Detection Notes

> **Technique:** Pass-the-Hash (T1550.002)  
> **Primary Signal:** EID 4624 — LogonType 3 + NTLM  
> **Confirmed:** 40 events in `winlogbeat-2026.08.25` at 2026-08-25T12:16:28Z  

---

## Detection Signal

| Field | Value | Significance |
|-------|-------|--------------|
| `event.code` | `4624` | Successful logon |
| `LogonType` | `3` | Network logon — no interactive session |
| `AuthenticationPackageName` | `NTLM` | Hash-based auth — Kerberos not used |
| `TargetUserName` | `Administrator` | High-privilege account targeted |
| `IpAddress` | `172.16.0.11` | Kali attacker — not a domain workstation |
| `agent.name` | `SOC-Lab-Endpoint` | Victim host confirmed |
| Total hits | **40** | High-volume — CME sends multiple auth attempts |

---

## ELK Query (KQL)

```kql
event.code: "4624"
AND winlog.event_data.LogonType: "3"
AND winlog.event_data.AuthenticationPackageName: "NTLM"
AND NOT winlog.event_data.IpAddress: ("127.0.0.1" OR "::1" OR "-")
```

---

## Supporting Events

| Event ID | Description | Relevance |
|----------|-------------|-----------|
| `4624` | Logon success | Primary PtH signal |
| `4625` | Logon failure | Pre-attack recon / failed hash attempts |
| `4648` | Explicit credentials logon | May appear alongside CME lateral movement |
| `4688` | New process created | RCE via `-x` flag creates cmd.exe process |
| `7045` | New service installed | CME service execution leaves traces |

---

## False Positive Considerations

- Legitimate NTLM network logons exist in older mixed environments
- Filter on source IP not matching known domain workstation list
- Scope alert to privileged accounts (`Administrator`, Domain Admins members)
- Volume spike of 40 events in under 1 second is anomalous — normal NTLM logons are isolated

---

## Sigma Rule

See [`detection/sigma/T1550.002-pass-the-hash.yml`](../../detection/sigma/T1550.002-pass-the-hash.yml)
