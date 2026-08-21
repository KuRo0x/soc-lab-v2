# INC-002 — Attack Timeline

> **Date:** 2026-08-12  
> **All times UTC** (from ELK `@timestamp` field, index `winlogbeat-2026.08.12`)

---

| Time (UTC) | T+ | Event | Source | Notes |
|------------|----|-------|--------|-------|
| 08:23:40 | T+0 | Attacker creates `users.txt` with target account `svc_asrep` | Kali | Setup step |
| 08:23:41 | T+1s | `impacket-GetNPUsers` executed against DC `172.16.0.5` | Kali | No credentials required |
| 08:23:43 | T+3s | KDC issues AS-REP without pre-auth challenge | DC (`172.16.0.5`) | EID 4768 generated, EncType 0x17, PreAuthType 0 |
| 08:23:43 | T+3s | `$krb5asrep$23$svc_asrep` hash captured to `/home/kali/asrep_hashes.txt` | Kali | See evidence 01 |
| 08:23:46 | T+6s | Hashcat `-m 18200` started against hash | Kali | rockyou / custom wordlist |
| 08:23:49 | T+9s | Hash cracked — password recovered | Kali | Status: Cracked, 1/1. See evidence 02 |
| ~08:24:00 | T+20s | Analyst queries Kibana: `event.code:4768 AND PreAuthType:0` | ELK | 2 documents returned. See evidence 03-04 |

---

## Detection Lag

| Stage | Time |
|-------|------|
| Attack start → hash captured | ~3 seconds |
| Hash captured → cracked | ~6 seconds |
| Attack start → Kibana-visible | ~17 seconds (Winlogbeat polling interval) |

> The attack is effectively instantaneous from an attacker's perspective. Detection relies entirely on the KDC logging EID 4768 — the window to prevent offline cracking is **zero** once the ticket is issued.
