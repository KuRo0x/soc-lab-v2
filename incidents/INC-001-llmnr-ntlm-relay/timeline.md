# INC-001 — Timeline

> All times GMT+1 (Morocco) | Executed: 2026-09-03

| Time (GMT+1) | Event | Source | Notes |
|-------------|-------|--------|-------|
| 12:05 | Responder 3.2.2.0 started on Kali (172.16.0.11) — eth0 | Kali terminal | `sudo responder -I eth0 -wv` — SMB=Off, HTTP=On |
| 12:05 | LLMNR + MDNS poisoned answers sent to 172.16.0.10 for FAKESERVER / FAKESERVER.local | Responder output | Kali responding to all broadcasts from Win10 |
| 12:05 | NTLMv2 hash captured — `SOC\Administrator` from 172.16.0.10 | Responder output — [SMB] | Hash: `Administrator::SOC:...` captured via SMB |
| 12:06 | ntlmrelayx started — relay mode to `smb://172.16.0.5` (DC) | Kali terminal | Initial attempt — DC has SMB signing required |
| 12:06 | Relay to DC SMB failed — `The client requested signing` | ntlmrelayx output | DC enforces SMB signing — relay blocked |
| 12:07 | nmap SMB signing check run against 172.16.0.5 and 172.16.0.10 | Kali terminal | DC: signing required ❌ / Win10: not required ✅ |
| 12:25 | Responder.conf updated — SMB=Off, HTTP=On | Kali terminal | `sed` commands applied to avoid port conflict with ntlmrelayx |
| 12:26 | ntlmrelayx relaunched — target `ldap://172.16.0.5`, `--no-smb-server`, `--escalate-user Administrator` | Kali terminal | HTTP relay to LDAP on DC |
| 12:26 | Responder relaunched — LLMNR/MDNS poisoning active | Kali terminal | HTTP=On, SMB=Off |
| 12:31 | Win10 browsed to `http://FAKESERVER/` via browser | Win10 — browser | Triggered HTTP NTLM auth → Responder poisoned name |
| 12:31 | ntlmrelayx received HTTP connection from 172.16.0.10 — attacking `ldap://172.16.0.5` | ntlmrelayx output | `SOC/ADMINISTRATOR@172.16.0.10` auth intercepted |
| 12:31 | **LDAP relay to DC SUCCEEDED** — `SOC/ADMINISTRATOR` authenticated against DC LDAP | ntlmrelayx output | `Authenticating...SUCCEED [1]` |
| 12:31 | ntlmrelayx enumerated Administrator privileges on domain | ntlmrelayx output | Found: Create user, Add to Enterprise Admins, Modify domain ACL |
| 12:31 | **Domain ACL modified** — Administrator granted `Replication-Get-Changes-All` | ntlmrelayx output | DCSync rights written to domain object |
| 12:31 | EID 4662 fired on DC — `WRITE_DAC` on domain object | Kibana — winlogbeat-2026.09.03 record 71400 | `SOC\Administrator` — AccessMask 0x40000 |
| 12:31 | EID 4662 fired on DC — `Write Property` on domain object | Kibana — winlogbeat-2026.09.03 record 71402 | `SOC\Administrator` — AccessMask 0x20 |
| 12:31 | Domain info dumped to lootdir — `aclpwn-20260903-073113.restore` saved | ntlmrelayx output | Full domain dump completed |

## Status
✅ Complete — 2026-09-03
