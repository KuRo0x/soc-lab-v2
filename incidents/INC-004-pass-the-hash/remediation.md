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

> **LAPS is the most direct fix for this specific attack.** The root cause of INC-004 was a shared local Administrator password across all machines — one hash worked on both Win10 and the DC. LAPS randomises the local Administrator password per machine on a scheduled rotation, so compromising one host's hash gives no lateral movement capability. This will be implemented in the lab in a future iteration (tracked below).

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

## Detection Blind Spots — What This Rule Would Miss

The Sigma rule and KQL query filter out machine accounts (`TargetUserName: *$`) and loopback IPs. However the following cases would evade or create noise in the current detection:

| Blind Spot | Explanation | Mitigation |
|------------|-------------|------------|
| **PtH against service accounts** | If an attacker uses PtH with a service account (e.g. `svc_http`, `krbtgt` in edge cases), `TargetUserName` won't end in `$` and will be caught — but analyst may dismiss it as a service account logon without investigating the source IP. | Enrich alerts with `IpAddress` context — any NTLM logon from a non-domain-workstation IP should be high priority regardless of the account name. |
| **PtH from a domain-joined host** | If the attacker pivots to a domain-joined machine first and runs CME from there, the source IP will look like a legitimate workstation. | Cross-reference with EID `4688` (new process) on the source host — CME creates cmd.exe/svchost as a child process. |
| **NTLM relay (not PtH)** | NTLM relay attacks produce similar `4624` + LogonType 3 + NTLM events but the attacker never possesses the hash. The rule correctly catches both — but the response differs. | Correlate with EID `4648` (explicit credentials) and network traffic to differentiate relay from direct PtH. |
| **Low-volume PtH (1 attempt)** | The 40-event spike in this lab was anomalous and easy to detect. A careful attacker making a single auth attempt would generate exactly 1 event — still caught by `> 0` threshold, but easier to dismiss as noise. | Tune alert with context: single NTLM logon from a non-standard IP to a privileged account should auto-escalate regardless of count. |
| **Kerberos-capable environment** | If NTLM is fully disabled (correct hardening), attackers switch to Kerberos-based lateral movement (Pass-the-Ticket, Overpass-the-Hash). This rule would produce zero hits. | Deploy complementary rules for EID `4768`/`4769` anomalies (INC-002/003 coverage). |

---

## LAPS Implementation Plan (Lab TODO)

LAPS directly eliminates the root cause of INC-004 — shared local Administrator credentials. Implementation steps for this lab:

1. **Download Windows LAPS** — built into Windows Server 2022 and Win10 22H2+, no separate download needed
2. **Extend AD schema** (run once on DC as Domain Admin):
   ```powershell
   Update-LapsADSchema
   ```
3. **Grant computers permission to update their own password attribute:**
   ```powershell
   Set-LapsADComputerSelfPermission -Identity "OU=Workstations,DC=soc,DC=lab"
   ```
4. **Deploy GPO** — `Computer Config → Admin Templates → LAPS`:
   - Password complexity: enabled
   - Password age: 30 days
   - Admin account name: `Administrator`
5. **Grant SOC team read access:**
   ```powershell
   Set-LapsADReadPasswordPermission -Identity "OU=Workstations,DC=soc,DC=lab" -AllowedPrincipals "SOC-Admins"
   ```
6. **Verify on Win10:**
   ```powershell
   Get-LapsADPassword -Identity SOC-Lab-Endpoint -AsPlainText
   ```
7. **Re-run INC-004 after LAPS deployment** — the subnet scan should return `(Pwn3d!)` on Win10 but fail on the DC, proving the control works.

> Tracked as lab TODO. Will be implemented before INC-007 to demonstrate defence-in-depth.

---

## Lab Cleanup

- [x] No persistent payload deployed — authentication only
- [x] NTLM hash documented but plaintext excluded from version control
- [ ] Rotate Administrator password after lab session
- [ ] Implement LAPS (tracked above)

---

## References

- [Microsoft Credential Guard](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard)
- [Microsoft LAPS Overview](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [Protected Users Security Group](https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group)
- [MITRE T1550.002](https://attack.mitre.org/techniques/T1550/002/)
