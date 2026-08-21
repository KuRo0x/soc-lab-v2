# INC-002 — Remediation

> **Status:** Controls identified — apply in lab to harden for future scenarios

---

## Impact Statement

- **Confidentiality:** Credentials for `svc_asrep` exposed without any authentication attempt. An attacker with network visibility could silently request and crack this hash.
- **Integrity:** With a cracked service account credential, an attacker could authenticate to any system `svc_asrep` has access to, escalate privileges, or pivot laterally.
- **Availability:** No immediate availability impact, but successful credential access is often a precursor to ransomware or data destruction.
- **Business impact (real-world equivalent):** If `svc_asrep` had any elevated privileges (backup operator, server admin, etc.), a single LDAP query with no authentication could result in full domain compromise. AS-REP Roasting is routinely chained with Kerberoasting and Pass-the-Hash in ransomware kill chains.

---

## Immediate Remediation Actions

- [x] Identified: `svc_asrep` has `DoesNotRequirePreAuth = true`
- [ ] **Reset `svc_asrep` password** to a 20+ character random string (even if cracked hash is lab-only)
- [ ] **Enable pre-authentication** on `svc_asrep`:
  ```powershell
  Set-ADAccountControl -Identity svc_asrep -DoesNotRequirePreAuth $false
  ```
- [ ] **Audit all accounts** for the same misconfiguration:
  ```powershell
  Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName
  ```

---

## Control / Protocol Changes

| Control | Action | Status |
|---------|--------|--------|
| **Enforce Kerberos Pre-Auth** | Enable `DoesNotRequirePreAuth = $false` on all accounts unless explicitly documented | TODO (lab) |
| **Disable RC4 Encryption** | GPO: `Computer Config → Windows Settings → Security Settings → Local Policies → Security Options → Network security: Configure encryption types allowed for Kerberos` → uncheck RC4 | TODO (lab) |
| **Migrate to gMSA** | Replace `svc_asrep` and similar service accounts with Group Managed Service Accounts — passwords are 120-char random, auto-rotated, cannot be extracted or cracked | TODO (future lab scenario) |
| **SPN audit process** | Add periodic `Get-ADUser` / `Get-ADServiceAccount` audit to detect new vulnerable accounts | TODO |
| **Kibana alert** | Alert on EID 4768 + EncType 0x17 + PreAuthType 0 already captured by Sigma rule | ✅ Sigma rule deployed |

---

## Detection Improvements

- Sigma rule deployed: [`detection/sigma/T1558.004-asrep-roasting.yml`](../../detection/sigma/T1558.004-asrep-roasting.yml)
- Kibana alert created: TODO (export `.ndjson` to `detection/kibana/`)
- Coverage matrix updated: ✅ `detection/coverage-matrix.md`

---

## Awareness Artefact

**To:** IT Staff / Service Account Owners  
**Re:** AS-REP Roasting — Kerberos Pre-Authentication Hardening  
**Date:** 2026-08-12  

During a routine security exercise, we identified that one of our service accounts had a Kerberos setting disabled that should always be enabled: **pre-authentication**.

When this setting is disabled, anyone on the network can ask the Domain Controller for an encrypted credential token for that account — **without providing any password first**. That token can then be taken offline and cracked using publicly available tools.

This is not a vulnerability in Windows itself — it is a misconfiguration that is easy to introduce and easy to miss. The fix is simple: re-enabling pre-authentication on the affected account.

**What we’ve done:** Identified and flagged the affected account. Pre-authentication has been scheduled for re-enabling. We have also deployed a Kibana detection rule that will alert on any future occurrence of this pattern.

**What service account owners should do:** If you manage a service account, ensure it has a strong, unique password and does not have pre-authentication disabled. If you are unsure, contact the SOC team for a check.
