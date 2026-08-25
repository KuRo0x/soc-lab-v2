# INC-004 — Remediation

> **Technique:** Pass-the-Hash (T1550.002)  
> **Tactic:** Lateral Movement  
> **Key Finding:** One NTLM hash compromised Win10 endpoint AND Domain Controller — full domain takeover from a single credential.

---

## Immediate Actions

1. **Identify all systems the hash authenticated to** — search ELK for `4624` events from `172.16.0.11` across all indices.
2. **Rotate the Administrator password immediately** — invalidates the current hash across all systems.
3. **Audit all systems for lateral movement artefacts** — check `4624`/`4648` events across Win10 and DC.

---

## Hardening Recommendations

### Credential Protection

| Control | Implementation | Priority |
|---------|----------------|----------|
| **Credential Guard** | GPO: `Device Guard → Virtualization Based Security → Enabled` | 🔴 High |
| **Protected Users Group** | Add `Administrator` and all privileged accounts — blocks NTLM entirely for members | 🔴 High |
| **LAPS** | Deploy Local Administrator Password Solution — unique password per machine, no hash reuse | 🔴 High |

### NTLM Restriction (GPO)

| Setting | Path | Value |
|---------|------|-------|
| Restrict NTLM outbound | `Computer Config → Security Options` | `Deny all accounts` |
| Restrict NTLM to remote servers | Same path | `Deny all` |
| Audit NTLM authentication | Same path | `Enable all` |

### Network Segmentation

- The flat `172.16.0.0/16` subnet allowed a single hash to reach both workstation and DC
- Implement VLANs: Tier 0 (DC, 172.16.0.5), Tier 1 (Servers), Tier 2 (Workstations, 172.16.0.10)
- pfSense firewall rules: block SMB (445) between tiers — workstations should never directly reach the DC over SMB
- This is tracked as a TODO in `configs/network/pfsense-rules.md`

---

## Lab Cleanup

- [x] No persistent payload deployed — authentication only
- [x] NTLM hash documented but plaintext excluded from version control
- [ ] Rotate Administrator password after lab session

---

## References

- [Microsoft Credential Guard](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard)
- [Microsoft LAPS Overview](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [Protected Users Security Group](https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group)
- [MITRE T1550.002](https://attack.mitre.org/techniques/T1550/002/)
