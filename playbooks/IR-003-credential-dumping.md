# IR-003 — Credential Dumping

## Detection
- **Sysmon Event ID 10** — Process access to LSASS
- **Event ID 4688** — Suspicious process creation (mimikatz, procdump)
- **ELK Query:**
```
winlog.event_data.TargetImage:*lsass* AND event.code:10
```

## Common Tools
- Mimikatz
- ProcDump + LSASS
- Impacket secretsdump
- DCSync (Event ID 4662 — replication rights)

## Investigation Steps
1. Check Sysmon Event ID 10 for LSASS access
2. Check parent process of the accessing process
3. Look for DCSync (Event ID 4662 with replication rights)
4. Check for new admin accounts created post-dump
5. Check network for Impacket secretsdump traffic (port 445)

## Containment
- Isolate source host immediately
- Reset ALL domain credentials (assume full compromise)
- Enable Protected Users security group
- Enable Credential Guard if not already enabled
