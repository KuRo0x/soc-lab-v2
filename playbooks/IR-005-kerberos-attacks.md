# IR-005 — Kerberos Attacks

> Covers: AS-REP Roasting (T1558.004) and Kerberoasting (T1558.003)  
> Related incidents: [INC-002](../incidents/INC-002-asrep-roasting/README.md) | [INC-003](../incidents/INC-003-kerberoasting/README.md)

---

## Detection

### AS-REP Roasting
- **Event ID 4768** — Kerberos TGT request with `PreAuthType: 0` and `TicketEncryptionType: 0x17` (RC4)
- **ELK Query:**
```
event.code:4768 AND winlog.event_data.PreAuthType:0 AND winlog.event_data.TicketEncryptionType:0x17
```

### Kerberoasting
- **Event ID 4769** — Kerberos service ticket request with `TicketEncryptionType: 0x17` (RC4) from a non-machine account
- **ELK Query:**
```
event.code:4769 AND winlog.event_data.TicketEncryptionType:0x17 AND NOT winlog.event_data.ServiceName:*$
```

---

## Common Tools Used by Attackers

| Tool | Technique |
|------|-----------|
| Impacket `GetNPUsers.py` | AS-REP Roasting — request TGT without pre-auth |
| Impacket `GetUserSPNs.py` | Kerberoasting — request service tickets for SPNs |
| Rubeus | Both — Windows-native Kerberos abuse |
| Hashcat `-m 18200` | Crack AS-REP hashes (etype 23) |
| Hashcat `-m 13100` | Crack Kerberoast hashes (etype 23) |
| John the Ripper | Alternative offline cracking |

---

## Investigation Steps

1. **Identify the source IP** from `winlog.event_data.IpAddress` in the alert
2. **Check which account was targeted** — `winlog.event_data.TargetUserName` (AS-REP) or `winlog.event_data.ServiceName` (Kerberoast)
3. **Correlate with 4624 / 4625** — did the attacker successfully authenticate after the ticket request?
4. **Check for lateral movement** — look for 4624 Type 3 logons from the attacker IP after the ticket event
5. **Review other ticket requests** — did the same source IP request multiple service tickets in a short window? (bulk Kerberoasting)
6. **Check if cracking succeeded** — look for authentication events using the compromised account after the attack window
7. **Identify account privileges** — run `Get-ADUser` / `Get-ADServiceAccount` to determine blast radius

---

## Containment

- **Disable the targeted account** immediately if compromise is confirmed
- **Reset the account password** with a strong random 25+ character password
- **Force Kerberos ticket expiration** — run `klist purge` on affected hosts or use `Invoke-UserLogoffAndForceKerberosTicketRefresh`
- **Block attacker IP** at pfSense firewall
- **Isolate attacker host** from the network if identified

---

## Remediation

| Control | AS-REP Roasting | Kerberoasting |
|---------|----------------|---------------|
| **Enforce pre-authentication** | ✅ Required — enable on ALL accounts | N/A |
| **Disable RC4 (etype 0x17)** | ✅ Reduces crackability | ✅ Reduces crackability |
| **Use AES256 only** | ✅ RC4 hashes uncrackable when AES enforced | ✅ AES Kerberoast hashes are computationally harder |
| **Use gMSA for service accounts** | N/A | ✅ Auto-rotated 120-char passwords — cracking infeasible |
| **Audit SPNs** | N/A | ✅ Remove unnecessary SPNs from sensitive accounts |
| **Privileged account separation** | ✅ Limit blast radius | ✅ Ensure service accounts have minimal privileges |

**PowerShell audit commands:**
```powershell
# Find AS-REP roastable accounts
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth

# Find Kerberoastable accounts (have SPN set)
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName, MemberOf
```

---

## References
- [MITRE T1558.004 — AS-REP Roasting](https://attack.mitre.org/techniques/T1558/004/)
- [MITRE T1558.003 — Kerberoasting](https://attack.mitre.org/techniques/T1558/003/)
- [Microsoft EID 4768](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4768)
- [Microsoft EID 4769](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4769)
