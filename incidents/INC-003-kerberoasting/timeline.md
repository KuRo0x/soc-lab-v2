# INC-003 — Attack Timeline

| Time | Host | Event | Notes |
|------|------|-------|-------|
| | DC (172.16.0.5) | SPN account `svc_http` created | Setup step |
| | Kali (172.16.0.11) | `impacket-GetUserSPNs` run | TGS requested |
| | DC (172.16.0.5) | EID 4769 generated | RC4 EncType 0x17 |
| | Kali (172.16.0.11) | Hash saved to `kerberoast.hash` | Offline cracking begins |
| | Kali (172.16.0.11) | Hashcat `-m 13100` — cracked | Password recovered |
| | ELK (172.16.0.4) | Alert triggered in Kibana | Detection confirmed |

> Fill in timestamps as you execute the attack.
