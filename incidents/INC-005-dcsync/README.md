# INC-005 — DCSync Attack

> **Status:** 🔲 Not started  
> **MITRE ATT&CK:** [T1003.006 — OS Credential Dumping: DCSync](https://attack.mitre.org/techniques/T1003/006/)  
> **Tactic:** Credential Access  
> **Severity:** Critical  

---

## Summary

DCSync abuses the legitimate Active Directory replication protocol to request password data directly from a Domain Controller — without ever touching LSASS on the DC. An account with `Replicating Directory Changes` and `Replicating Directory Changes All` permissions can impersonate another DC and ask for any user's password hash, including `krbtgt`.

---

## ⚠️ Lab Setup Note — Intentional Misconfiguration

To simulate this attack, `svc_asrep` will be granted DCSync rights via ADUC (Delegate Control). This is an **intentional lab misconfiguration** that simulates a realistic scenario: a service account that has been over-permissioned, compromised by a careless admin, or abused by an insider threat.

In a real environment, DCSync rights should only ever be held by Domain Controllers themselves and explicitly authorised replication partners (e.g. Azure AD Connect). Any other account holding these permissions is a critical misconfiguration — and a common finding in red team engagements.

**This setup step is the misconfiguration being simulated — not part of the attack itself.**

---

## Environment

| Component | Value |
|-----------|-------|
| Domain | `SOC.LAB` |
| Domain Controller | `SOC-Lab-DC` / `172.16.0.5` |
| Attacker (Kali) | `SOC-Lab-Attacker` / `172.16.0.11` |
| Abused account | `svc_asrep` (over-permissioned service account) |
| Tool | `impacket-secretsdump` |
| Credential required | `svc_asrep` plaintext (cracked in INC-002) |

---

## Pre-requisites

### Step 1 — Grant DCSync rights to svc_asrep (DC — ADUC)

1. RDP into `SOC-Lab-DC` (172.16.0.5) as Domain Admin
2. Open **Active Directory Users and Computers**
3. Right-click the **domain root** (`soc.lab`) → **Delegate Control**
4. Add `svc_asrep` as the delegated user
5. Select **"Create a custom task to delegate"**
6. Scope: **"This folder, existing objects..."**
7. Permissions — tick both:
   - `Replicating Directory Changes`
   - `Replicating Directory Changes All`
8. Finish

> This grants `svc_asrep` the ability to pull password hashes from the DC via replication — the exact permission DCSync exploits.

### Step 2 — Verify impacket is available on Kali

```bash
which impacket-secretsdump
```

---

## Attack (Kali)

```bash
impacket-secretsdump soc.lab/svc_asrep:'Summer2024!'@172.16.0.5
```

Expected output includes:
- `Administrator:500:aad3...:<NTLM_HASH>:::`
- `krbtgt:502:aad3...:<NTLM_HASH>:::`
- All domain user hashes

---

## Detection Signal

| Field | Value |
|-------|-------|
| Event ID | `4662` |
| Object type | `%{19195a5b-6da0-11d0-afd3-00c04fd930c9}` (domainDNS) |
| Access mask | `0x100` (Replicating Directory Changes) |
| Subject account | `svc_asrep` |
| Host | `SOC-Lab-DC` |

**KQL:**
```kql
event.code: "4662"
AND winlog.event_data.AccessMask: "0x100"
AND NOT winlog.event_data.SubjectUserName: (*$ OR MSOL_*)
```

---

## Deliverables

- [ ] Attack executed + output captured
- [ ] ELK detection confirmed (EID 4662)
- [ ] `incidents/INC-005-dcsync/` writeup
- [ ] `detection/sigma/T1003.006-dcsync.yml`
- [ ] `detection/kibana/T1003.006-dcsync-alert.ndjson`
- [ ] sigma-cli conversion + validation
- [ ] Evidence screenshots
- [ ] STATUS.md updated
