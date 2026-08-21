# INC-003 — Attack Timeline

> **Date:** 2026-08-20  
> **All times UTC** (from ELK `@timestamp` field, index `winlogbeat-2026.08.20`)

---

| Time (UTC) | T+ | Event | Source | Notes |
|------------|----|-------|--------|-------|
| ~Session start | T+0 | `svc_http` SPN confirmed: `HTTP/soc-lab-dc.soc.lab` | DC / Kali | Pre-req check via `GetUserSPNs.py -request` |
| T+0 | T+0 | `impacket-GetUserSPNs` executed with valid domain credentials | Kali (`172.16.0.11`) | Requests TGS for all SPN-bearing accounts |
| T+~2s | T+2s | KDC issues TGS ticket encrypted with `svc_http` password hash (RC4) | DC (`172.16.0.5`) | EID 4769 generated, `TicketEncryptionType: 0x17` |
| T+~2s | T+2s | `$krb5tgs$23$*svc_http*` hash written to output file | Kali | Service ticket captured |
| T+~5s | T+5s | Hashcat `-m 13100` started against hash | Kali | rockyou / custom wordlist |
| T+~10s | T+10s | Hash cracked — password recovered | Kali | `Status: Cracked`, 1/1 |
| T+~17s | T+17s | EID 4769 visible in Kibana | ELK (`172.16.0.4`) | Record `52849`, index `winlogbeat-2026.08.20` |

> **Note:** Exact timestamps were not recorded during this session. The above are derived from evidence screenshots and ELK record numbers. Precise `@timestamp` values should be confirmed from the actual ELK record when returning to the lab.

---

## Detection Lag

| Stage | Time |
|-------|------|
| Attack start → TGS ticket issued | ~2 seconds |
| TGS ticket issued → hash cracked | ~8–10 seconds |
| Attack start → Kibana-visible | ~17 seconds (Winlogbeat polling interval) |

> Like AS-REP Roasting, cracking happens entirely offline after ticket issuance. The KDC log is the **only** opportunity to detect the initial request — after the ticket is in the attacker's hands, detection is too late to prevent credential exposure.
