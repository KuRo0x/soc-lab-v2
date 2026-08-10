# IR-002 — Lateral Movement

## Detection
- **Event IDs:** 4624 (Logon Type 3), 4648, 7045 (new service)
- **Sysmon:** Event ID 3 (Network connection), Event ID 1 (Process create)
- **ELK Query:**
```
event.code:4624 AND winlog.event_data.LogonType:3 AND NOT source.ip:172.16.0.5
```

## Common Techniques
- Pass-the-Hash (PtH)
- Pass-the-Ticket (PtT)
- WMI / PSExec
- Evil-WinRM

## Investigation Steps
1. Identify source and destination hosts
2. Check Sysmon network events for SMB/WMI/RDP connections
3. Check for new services or scheduled tasks created remotely (Event ID 7045, 4698)
4. Check for credential dumping (Event ID 4688 — LSASS access)
5. Build timeline across all affected hosts

## Containment
- Isolate affected hosts
- Revoke Kerberos tickets (`klist purge` on affected hosts)
- Reset compromised credentials
