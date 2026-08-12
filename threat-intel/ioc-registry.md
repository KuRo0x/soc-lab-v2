# Central IOC Registry

Aggregated indicators of compromise across all completed lab scenarios.

> Individual scenario IOCs are in `threat-scenarios/INC-XXX/iocs.md`.
> This file is the consolidated view for cross-scenario correlation.

---

## Network IOCs

| IP / Host | Port | Protocol | Context | Scenario |
|-----------|------|----------|---------|----------|
| `172.16.0.11` (Kali) | 39628 | Kerberos/TCP | AS-REP roast source | INC-002 |
| `172.16.0.5` (SOC-Lab-DC) | 88 | Kerberos/TCP | Kerberos KDC — target | INC-002 |

## Host IOCs

| Indicator | Type | Context | Scenario |
|-----------|------|---------|----------|
| `impacket-GetNPUsers` | Tool | AS-REP hash extraction | INC-002 |
| `hashcat -m 18200` | Tool | Kerberos AS-REP offline crack | INC-002 |
| `svc_asrep` | Account | Vulnerable AD account | INC-002 |
| `$krb5asrep$23$` | Hash prefix | RC4 AS-REP hash format | INC-002 |

## Log-Based IOCs

| Event ID | Field | Value | Context | Scenario |
|----------|-------|-------|---------|----------|
| 4768 | TicketEncryptionType | `0x17` | RC4 TGT request | INC-002 |
| 4768 | PreAuthType | `0` | PreAuth disabled | INC-002 |
| 4768 | TargetUserName | `svc_asrep` | Targeted account | INC-002 |
