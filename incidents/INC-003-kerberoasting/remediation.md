# INC-003 — Remediation

> **Status:** Controls identified — apply in lab to harden for future scenarios

---

## Impact Statement

- **Confidentiality:** Service ticket for `svc_http` extracted using valid domain credentials. The encrypted ticket is crackable offline with no further network interaction — no lockout, no alerts on the cracking phase.
- **Integrity:** With a cracked `svc_http` credential, an attacker can authenticate as that service account to any system where it has access. If the account has local admin rights, this chains directly into lateral movement.
- **Availability:** No immediate impact, but Kerberoasting is a standard pre-ransomware step: compromise service accounts → gain local admin → deploy ransomware.
- **Business impact (real-world equivalent):** Service accounts are often over-privileged and their passwords rarely rotated. A Kerberoasted service account with DA membership (a common misconfiguration) = full domain compromise. Reported in virtually every red team engagement against Windows environments.

---

## Immediate Remediation Actions

- [x] Identified: `svc_http` has an SPN registered, uses RC4 encryption, and has a weak password
- [ ] **Reset `svc_http` password** to a 25+ character random string:
  ```powershell
  Set-ADAccountPassword -Identity svc_http -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "[long-random-password]" -Force)
  ```
- [ ] **Audit all SPN-bearing accounts:**
  ```powershell
  Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName, PasswordLastSet | Select Name, SamAccountName, PasswordLastSet
  ```

---

## Control / Protocol Changes

| Control | Action | Status |
|---------|--------|--------|
| **Disable RC4 Kerberos** | GPO: `Network security: Configure encryption types allowed for Kerberos` → uncheck RC4 (0x17), require AES-128/AES-256 only | TODO (lab) |
| **Enforce strong passwords on SPNs** | SPN-bearing accounts must have 25+ char passwords — document in AD hardening policy | TODO |
| **Migrate to gMSA** | Replace `svc_http` with a Group Managed Service Account — 120-char auto-rotating passwords, technically immune to Kerberoasting | TODO (future lab scenario) |
| **SPN audit process** | Periodic: `Get-ADUser -Filter {ServicePrincipalName -ne null}` — alert on new SPNs added outside change process | TODO |
| **Remove unnecessary SPNs** | Audit whether `HTTP/soc-lab-dc.soc.lab` SPN on `svc_http` is actually needed. Remove if not. | TODO (lab) |
| **Kibana alert** | Alert on EID 4769 + EncType 0x17 + non-machine ServiceName captured by Sigma rule | ✅ Sigma rule deployed |

---

## Detection Improvements

- Sigma rule deployed: [`detection/sigma/T1558.003-kerberoasting.yml`](../../detection/sigma/T1558.003-kerberoasting.yml)
- Kibana alert created: TODO (export `.ndjson` to `detection/kibana/`)
- Coverage matrix updated: ✅ `detection/coverage-matrix.md`

---

## Awareness Artefact

**To:** IT Staff / Service Account Owners  
**Re:** Kerberoasting — Service Account Hardening  
**Date:** 2026-08-20  

During a security exercise, we successfully extracted and cracked the password of a domain service account using a technique called **Kerberoasting**.

Unlike most attacks, this one requires no special privileges — any valid domain user account can request a service ticket for any service registered in Active Directory. That ticket is encrypted with the service account’s password and can be taken offline and cracked. The domain controller logs the request, but the cracking happens entirely on the attacker’s machine with no further network traffic.

**What makes an account vulnerable:** any account with a Service Principal Name (SPN) registered and a crackable password (especially one set by a human rather than auto-generated).

**What we’ve done:** Identified all SPN-bearing accounts. Scheduled password resets to 25+ character random strings. Deployed a detection rule that alerts on RC4-encrypted TGS requests. Evaluating migration of service accounts to Group Managed Service Accounts (gMSA), which use auto-rotating 120-character passwords and are technically immune to this attack.

**What service account owners should do:** Do not set service account passwords manually using dictionary words or short strings. Rotate any password you have set yourself with a password-manager-generated 25+ character string immediately, and request a migration to gMSA at the next change window.
