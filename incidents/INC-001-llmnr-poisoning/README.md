# INC-001 — LLMNR Poisoning + NTLM Relay

## Scenario

Attacker (Kali, 172.16.0.11) runs Responder to poison LLMNR/NBT-NS broadcasts. Victim (Win10, 172.16.0.10) attempts to resolve a non-existent hostname, broadcasting an LLMNR query. Responder intercepts, captures NTLMv2 hash, and optionally relays it.

**Attacker steps:**
1. `sudo responder -I eth0 -rdwv`
2. Wait for victim LLMNR broadcast
3. Capture NTLMv2 hash
4. Optional relay: `impacket-ntlmrelayx -tf targets.txt -smb2support`

## MITRE ATT&CK Mapping

| Field | Value |
|-------|-------|
| Tactic | Credential Access |
| Technique | T1557.001 — LLMNR/NBT-NS Poisoning and SMB Relay |
| Platform | Windows |

## Detection Logic
See [`detection.md`](./detection.md)

## Status
🔲 TODO — not yet executed
