# INC-001 — LLMNR Poisoning + NTLM Relay

## Scenario

The attacker is positioned on the LAN (Kali — 172.16.0.11). When a Windows host (Win10 — 172.16.0.10) broadcasts an LLMNR/NBT-NS query for a non-existent hostname, Responder on Kali responds with a poisoned answer, capturing the victim's NTLMv2 challenge-response hash. The relay variant (ntlmrelayx) forwards the captured NTLM authentication to a second host (DC — 172.16.0.5) to achieve unauthenticated lateral movement or RCE without cracking the hash.

**Tools used:** Responder, impacket-ntlmrelayx, CrackMapExec (verification)

## MITRE ATT&CK Mapping

| Field | Value |
|-------|-------|
| Tactic | Credential Access / Lateral Movement |
| Technique | T1557 — Adversary-in-the-Middle |
| Sub-technique | T1557.001 — LLMNR/NBT-NS Poisoning and SMB Relay |
| Platform | Windows / Network |

## Detection Logic

See [`detection.md`](./detection.md)

## Evidence

See [`evidence/`](./evidence/) — sanitized screenshots and log excerpts

## Response

1. Identify source IP sending poisoned LLMNR responses (Suricata / Wireshark)
2. Isolate attacker host at pfSense firewall (block 172.16.0.11)
3. Reset credentials for any accounts whose NTLM hashes were captured
4. Disable LLMNR and NBT-NS via GPO across all Windows endpoints
5. Review EID 4624/4625 for any successful relay authentications
6. Post-incident: audit SMB signing enforcement across all hosts

## Lessons / Gaps

> To be filled after execution.

- What worked
- What was missed and why
- What to add next

## Status
🔄 In Progress
