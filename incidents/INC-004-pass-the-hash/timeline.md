# INC-004 — Attack Timeline

> **Date:** 2026-08-25  
> **Technique:** Pass-the-Hash (T1550.002)  
> **Note:** All times are UTC+1 (local lab time) unless explicitly marked `Z` (UTC).

---

| Time (UTC+1) | Actor | Action | Evidence |
|--------------|-------|--------|----------|
| ~19:50 | KuRo (Kali) | Verified CrackMapExec installed — first-run init completed | CME terminal output |
| ~19:58 | KuRo (Kali) | Confirmed Administrator plaintext credential valid via `-p` flag | CME `[+] (Pwn3d!)` |
| ~20:00 | KuRo (Kali) | Generated NTLM hash `217cac874bc6e41a6fec9b06d2eee7d5` from plaintext via Python hashlib | Terminal output |
| ~20:05 | KuRo (Kali) | Executed PtH: `crackmapexec smb 172.16.0.10 -u Administrator -H 217cac...` | CME `[+] (Pwn3d!)` |
| ~20:16 (13:16:28Z) | Win10 Victim | 40× EID 4624 generated — LogonType 3, NTLM, source 172.16.0.11 | Kibana / Winlogbeat |
| ~20:09 | KuRo (Kali) | RCE confirmed: `whoami` → `soc\administrator`, `hostname` → `SOC-Lab-Endpoint` | CME `-x` output |
| ~20:09 | KuRo (Kali) | `net user` — 5 local accounts enumerated on victim | CME `-x` output |
| ~20:15 | KuRo (Kali) | `ipconfig /all` — full network config exposed remotely | CME `-x` output |
| ~20:18 | KuRo (Kali) | Subnet scan `172.16.0.0/24` — Win10 AND DC both `(Pwn3d!)` | CME subnet scan |
| ~20:23 | KuRo (ELK) | Confirmed 40 detection hits in `winlogbeat-2026.08.25` index | Kibana screenshot |
