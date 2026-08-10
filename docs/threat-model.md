# 🎯 Threat Model

## What This Lab Is Designed To Detect

This lab focuses on **Active Directory-centric attack chains** — the most common pattern in real enterprise breaches. The threat model is built around an attacker who:

1. Has initial foothold on the network (phishing, LLMNR poisoning, or password spray)
2. Has no domain credentials initially
3. Goal: escalate to Domain Admin, move laterally, exfiltrate data

This mirrors the kill chain used in most ransomware and APT intrusions against Windows/AD environments.

---

## Threat Actor Profile

| Property | Value |
|----------|-------|
| Type | Opportunistic / red team simulation |
| Initial access | Phishing, LLMNR poisoning, password spray |
| Tools | Impacket, Responder, BloodHound, Mimikatz, CrackMapExec |
| Goal | Domain Admin → lateral movement → data access |
| Persistence | Scheduled tasks, new admin accounts, DCSync |

---

## Out of Scope (v2)

- Cloud attacks (AWS/Azure/GCP)
- Supply chain attacks
- Physical security
- Nation-state 0-day exploitation

---

## Detection Coverage Goals

| MITRE Tactic | Techniques | Detection |
|--------------|-----------|-----------|
| Initial Access | T1566, T1078 | Sysmon + Winlogbeat |
| Credential Access | T1557, T1558, T1003 | Sysmon EID 10, Security logs EID 4768/4769 |
| Lateral Movement | T1550, T1021 | Sysmon EID 3, logon events EID 4624 |
| Execution | T1059, T1204 | Sysmon EID 1 |
| Command & Control | T1071, T1095 | Sysmon EID 3, Suricata (TODO) |
| Persistence | T1053, T1543 | Sysmon EID 11/13, Windows EID 7045 |

---

## What Differentiates This Lab From v1

> v1 (SOC-Detection-Lab) focused on broad, unstructured log collection — "surveillance" mode.
> v2 is **threat-model-driven**: every scenario maps to a real AD attack chain, with Sigma rules, MITRE mapping, and an honest gaps section.

| | v1 | v2 |
|--|-------|------|
| Approach | Broad surveillance | Adversary emulation |
| Detection content | Ad hoc queries | Versioned Sigma rules |
| Documentation | Basic | Professional incident template |
| Malware capability | None | FLARE-VM (isolated) |
| Threat model | Not defined | Explicitly documented |

---

## Known Gaps & Limitations

- No network IDS (Suricata not yet deployed)
- No cloud environment
- No deception tech (honeypots, canary tokens)
- No UEBA
- Flat network (no VLAN segmentation)
- Kali on same subnet as victims (some scenarios less realistic)
