# 🔥 FLARE-VM — Malware Analysis

## Host
- **IP:** 172.16.0.30
- **Hostname:** DESKTOP-AL0PPK8
- **User:** analyst
- **OS:** Windows 10 + FLARE-VM toolkit

## Design Decision — ISOLATED BY DESIGN

> ⚠️ **FLARE-VM has NO telemetry, NO Winlogbeat, NO Sysmon.**  
> This is intentional. Running EDR/monitoring agents on a malware analysis machine:
> - Adds noise that interferes with analysis
> - Can be detected by malware samples
> - Could inadvertently ship malware artifacts to ELK

## Network Isolation
- [x] pfSense rule `BLOCK-FLARE-VM-OUTBOUND` — blocks all outbound from 172.16.0.30
- [x] Can reach DC (172.16.0.5) — TCP OK
- [x] Can reach ELK (172.16.0.4) — TCP OK (same subnet, no routing through pfSense)
- [x] Cannot reach pfSense gateway (172.16.0.1) — blocked ✅

## Tool Inventory (TODO — fill in)
| Tool | Installed | Notes |
|------|-----------|-------|
| Ghidra | ? | Static analysis |
| x64dbg | ? | Dynamic analysis / debugging |
| PEStudio | ? | PE analysis |
| FakeNet-NG | ? | Network simulation |
| Wireshark | ? | Packet capture |
| Process Hacker | ? | Process monitoring |
| CFF Explorer | ? | PE editor |
| FLOSS | ? | String extraction |

## Usage Workflow
1. Transfer sample to FLARE-VM (via shared folder or USB — never over network)
2. Take VM snapshot before detonation
3. Perform static analysis (PEStudio, Ghidra, FLOSS)
4. Perform dynamic analysis (x64dbg, FakeNet-NG, Wireshark)
5. Document findings
6. Revert to clean snapshot after analysis
