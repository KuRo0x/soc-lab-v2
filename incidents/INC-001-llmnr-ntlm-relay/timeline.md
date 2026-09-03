# INC-001 — Timeline

> Fill in timestamps during/after execution. All times GMT+1 (Morocco).

| Time (GMT+1) | Event | Source | Notes |
|-------------|-------|--------|-------|
| T+0 | Responder started on Kali (172.16.0.11) — LAN interface | Kali terminal | `sudo responder -I eth0 -wv` |
| T+? | Win10 broadcasts LLMNR query for non-existent hostname | Wireshark / Suricata | Triggered by UNC path or mistyped share |
| T+? | Kali responds with poisoned LLMNR answer | Responder output | NTLMv2 challenge sent to victim |
| T+? | Win10 sends NTLMv2 hash to Kali | Responder output | Hash captured — `[+] NTLMv2 Hash:` |
| T+? | ntlmrelayx relays auth to DC (172.16.0.5) | ntlmrelayx output | Relay attempt |
| T+? | EID 4624 / 4625 observed in ELK | Kibana — winlogbeat-* | LogonType 3, NTLM, source 172.16.0.11 |
| T+? | Suricata LLMNR alert fires | Kibana — suricata-* | Signature match on poisoning traffic |
| T+? | Kibana detection rule triggered | Kibana alerts | Rule: Suspicious NTLM Lateral Movement |

## Status
🔲 Not yet executed
