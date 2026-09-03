# INC-001 — Remediation

> Fill this in immediately after the incident write-up is complete.

---

## Impact Statement

- **Confidentiality:** NTLMv2 hashes exposed — offline cracking possible; cleartext credentials at risk if hash is weak
- **Integrity:** Successful relay grants attacker code execution as the relayed user — privilege escalation if high-priv account is targeted
- **Availability:** No immediate availability impact — silent attack with no service disruption
- **Business impact:** Full domain compromise possible if a Domain Admin authenticates while Responder is running; lateral movement to all SMB-signing-disabled hosts

---

## Immediate Remediation Actions

- [ ] Block Kali (172.16.0.11) at pfSense firewall
- [ ] Reset credentials for any account whose hash was captured
- [ ] Revoke any active sessions established via relay (`klist purge` on affected hosts)
- [ ] Check EID 4624 LogonType 3 NTLM for any successful relay sessions — scope the breach

---

## Control / Protocol Changes

| Control | Action | Owner | Status |
|---------|--------|-------|--------|
| Disable LLMNR | GPO: Computer Config → Admin Templates → Network → DNS Client → Turn off multicast name resolution → Enabled | SysAdmin | TODO |
| Disable NBT-NS | NIC properties → TCP/IP → Advanced → WINS → Disable NetBIOS over TCP/IP | SysAdmin | TODO |
| Enable SMB Signing | GPO: Microsoft network server: Digitally sign communications (always) → Enabled | SysAdmin | TODO |
| Restrict NTLM | GPO: Network security: Restrict NTLM: Outgoing NTLM traffic → Deny all | SysAdmin | TODO |

---

## Detection Improvements

- Sigma rule deployed: [`detection/sigma/T1557.001-llmnr-ntlm-relay.yml`](../../detection/sigma/T1557.001-llmnr-ntlm-relay.yml)
- Kibana alert created: TODO
- Suricata LLMNR rule confirmed: TODO

---

## Awareness Artefact

**To:** IT Staff / Network Administrators  
**Re:** LLMNR/NBT-NS Poisoning — Security Control Implemented  
**Date:** 2026-09-03  

We recently simulated and detected an attack where an adversary on the internal network intercepted Windows name-resolution broadcasts to steal user credentials without any user interaction. The attacker needed only to be on the same network segment.

As a result, we have disabled LLMNR and NBT-NS via Group Policy and enforced SMB signing across all endpoints. Going forward, all service accounts and workstation credentials should be treated as potentially exposed if SMB signing was not enforced during the window of exposure.

If you manage service accounts or shared drives, please verify SMB signing is enforced and reset any credentials used on affected hosts.
