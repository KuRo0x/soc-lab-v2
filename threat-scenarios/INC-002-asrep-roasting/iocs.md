# INC-002 — Indicators of Compromise

## Network IOCs

| Type | Value | Context |
|------|-------|---------|
| Source IP | `172.16.0.11` | Kali attacker — sent AS-REP request |
| Destination IP | `172.16.0.5` | SOC-Lab-DC — Kerberos KDC |
| Destination Port | `88/TCP` | Kerberos |
| Source Port | `39628` | Observed in live event |

## Host IOCs

| Type | Value | Context |
|------|-------|---------|
| Tool | `impacket-GetNPUsers` | Used to request AS-REP hash |
| Tool | `hashcat -m 18200` | Mode 18200 = Kerberos AS-REP |
| Account | `svc_asrep` | Vulnerable account targeted |
| Hash Type | `$krb5asrep$23$` | RC4-HMAC AS-REP hash prefix |

## Log IOCs

| Event ID | Field | Value | Meaning |
|----------|-------|-------|---------|
| 4768 | `TicketEncryptionType` | `0x17` | RC4 — weak cipher, attacker-requested |
| 4768 | `PreAuthType` | `0` | Pre-auth disabled — account is vulnerable |
| 4768 | `Status` | `0x0` | Success — hash was issued |
| 4768 | `TargetUserName` | `svc_asrep` | Account targeted |
