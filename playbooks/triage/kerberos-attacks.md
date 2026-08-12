# Triage — Kerberos-Based Attacks

Covers: INC-002 (AS-REP Roasting), INC-003 (Kerberoasting)

---

## Step 1 — Identify the Alert

| If you see... | Likely Technique |
|---------------|------------------|
| Event 4768 + TicketEncryptionType `0x17` + PreAuthType `0` | AS-REP Roasting (T1558.004) |
| Event 4769 + TicketEncryptionType `0x17` from non-service host | Kerberoasting (T1558.003) |
| Multiple 4768/4769 events for different accounts from same IP | Automated enumeration |

## Step 2 — ELK Queries

```kql
# AS-REP Roasting
event.code: "4768" AND winlog.event_data.TicketEncryptionType: "0x17" AND winlog.event_data.PreAuthType: "0"

# Kerberoasting
event.code: "4769" AND winlog.event_data.TicketEncryptionType: "0x17"

# Both — from same source IP
winlog.event_data.IpAddress: "::ffff:<ATTACKER_IP>" AND event.code: ("4768" OR "4769")
```

## Step 3 — Scope Assessment

```powershell
# Check all accounts with PreAuth disabled
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName, Enabled

# Check all accounts with SPNs (Kerberoastable)
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName | Select Name, SamAccountName, ServicePrincipalName
```

## Step 4 — Containment

```powershell
# Disable the targeted account immediately
Disable-ADAccount -Identity svc_asrep

# Re-enable pre-auth
Set-ADAccountControl -Identity svc_asrep -DoesNotRequirePreAuth $false

# Force password reset
Set-ADAccountPassword -Identity svc_asrep -Reset -NewPassword (Read-Host -AsSecureString)
```

## Step 5 — Document & Close

- Record source IP, account targeted, timestamp
- Update `threat-scenarios/INC-002-asrep-roasting/iocs.md`
- Confirm Sigma rule fired correctly
- Update `detection/coverage-matrix.md` if gaps found
