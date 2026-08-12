# INC-001 — LLMNR/NBT-NS Poisoning

> **Status:** 🔲 Pending
> **MITRE ATT&CK:** [T1557.001 - Adversary-in-the-Middle: LLMNR/NBT-NS Poisoning](https://attack.mitre.org/techniques/T1557/001/)
> **Tactic:** Credential Access
> **Tool:** Responder
> **Difficulty:** Low

---

## Overview

When a Windows host fails to resolve a hostname via DNS, it falls back to LLMNR (Link-Local Multicast Name Resolution) and NBT-NS (NetBIOS Name Service) — broadcasting the query to the local network segment. An attacker running Responder can answer these broadcasts with a poisoned response, capturing NTLMv2 challenge/response hashes from the victim without any user interaction.

---

## Lab Environment

| Component | Value |
|-----------|-------|
| Domain | `soc.lab` |
| DC | `SOC-Lab-DC` (172.16.0.5) |
| Attacker (Kali) | `172.16.0.11` |
| Victim | Win10 endpoint (172.16.0.10) |
| Tool | Responder + Hashcat (NTLMv2 mode 5600) |

---

## Status

🔲 **Not yet executed.** See [STATUS.md](../../STATUS.md) for overall lab progress.

When ready, follow the scenario template in `playbooks/templates/scenario-template.md`.
