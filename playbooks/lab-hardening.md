# 🛡️ soc-lab-v2 — Full Lab Hardening Guide

> This document covers hardening recommendations for every component in the soc-lab-v2 stack.
> Organized by layer: network → endpoints → identity → telemetry → attacker opsec.
> Each section maps to the attack scenarios in `scenarios/` so you understand *why* each control matters.

---

## 🔥 Why This Matters

This lab is deliberately misconfigured to simulate real-world attack paths. Every vulnerability here has been seen in actual enterprise environments. The controls below are what separates a breached organization from a resilient one.

---

## 1. 🌐 Network — pfSense (172.16.0.1)

### Current State
- Flat network — all VMs can reach each other
- FLARE-VM outbound blocked
- No VLAN segmentation yet

### Hardening Controls

#### VLAN Segmentation (Planned v2.1)
```
VLAN 10 — Management (ELK, admin hosts)
VLAN 20 — Attack (Kali) — isolated, no access to VLAN 10
VLAN 30 — Victim (DC, Win10, Ubuntu)
VLAN 40 — Analysis (FLARE-VM) — no outbound
```
- Prevents lateral movement between lab segments
- Forces attacker traffic through chokepoints visible to Suricata

#### Firewall Rules
- [ ] Block all traffic from VLAN 20 (Kali) to VLAN 10 (Management) by default
- [ ] Allow only specific ports for attack scenarios (e.g., 88/TCP for Kerberos)
- [ ] Log all denied traffic to ELK via Filebeat/Syslog
- [ ] Block LLMNR (UDP 5355) and NetBIOS (UDP 137-138) at the firewall level

#### Suricata IDS (Not Yet Deployed)
- [ ] Deploy Suricata on pfSense
- [ ] Enable ET Open ruleset
- [ ] Forward Suricata alerts to ELK via Filebeat
- [ ] Create custom rules for lab attack signatures

#### DNS Hardening
- [ ] Restrict DNS queries to DC only (172.16.0.5)
- [ ] Block external DNS from victim VMs — forces all resolution through controlled DNS
- [ ] Log DNS queries on the DC for threat hunting

---

## 2. 🏛️ Active Directory & Domain Controller (172.16.0.5)

### INC-001 — LLMNR Poisoning Prevention
```
GPO Path: Computer Config → Admin Templates → Network → DNS Client
→ Turn off multicast name resolution: ENABLED

GPO Path: Computer Config → Admin Templates → Network → Lanman Workstation
→ Enable insecure guest logons: DISABLED
```
- [ ] Disable LLMNR via GPO on all domain machines
- [ ] Disable NetBIOS over TCP/IP on all NICs
- [ ] Disable WPAD (Web Proxy Auto-Discovery)

### INC-002 — AS-REP Roasting Prevention
```powershell
# Audit all accounts with PreAuth disabled
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} `
  -Properties DoesNotRequirePreAuth | Select Name, SamAccountName

# Re-enable PreAuth on any found accounts
Set-ADAccountControl -Identity <username> -DoesNotRequirePreAuth $false
```
- [ ] Enforce Kerberos pre-authentication on ALL accounts — no exceptions
- [ ] Disable RC4-HMAC via GPO: `Network security: Configure encryption types allowed for Kerberos` → AES128/AES256 only
- [ ] Migrate service accounts to **Group Managed Service Accounts (gMSA)** — auto-rotating 120-char passwords
- [ ] Add all privileged service accounts to **Protected Users** security group
- [ ] Schedule quarterly audit of PreAuth settings via scheduled task or script

### INC-003 — Kerberoasting Prevention
- [ ] Use gMSA for all service accounts — passwords are 120 chars, practically uncrackable
- [ ] Audit SPNs: `Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName`
- [ ] Remove unnecessary SPNs from user accounts — use computer accounts for services
- [ ] Monitor for 4769 events with RC4 encryption type (same 0x17 signal as AS-REP)

### INC-004 — Pass-the-Hash Prevention
- [ ] Enable **Protected Users** group for all privileged accounts
- [ ] Disable NTLM authentication via GPO where possible: `Network security: Restrict NTLM`
- [ ] Enable **Credential Guard** on Windows 10/2019+ hosts
- [ ] Never log in to untrusted machines with Domain Admin credentials
- [ ] Use **tiered admin model**: separate accounts for workstation, server, DC administration

### INC-005 — DCSync Prevention
```powershell
# Find accounts with dangerous replication rights
Get-ACL "AD:\DC=soc,DC=lab" | Select -ExpandProperty Access |
  Where-Object {$_.ActiveDirectoryRights -match "Replication"} |
  Select IdentityReference, ActiveDirectoryRights
```
- [ ] Only Domain Controllers should have `DS-Replication-Get-Changes-All` rights
- [ ] Alert on any non-DC account with replication rights
- [ ] Enable replication auditing — monitor Event IDs 4662 with replication GUIDs

### General AD Hardening
- [ ] Implement **AdminSDHolder** protection for privileged groups
- [ ] Enable **Fine-Grained Password Policy** — 25+ char minimum for service accounts
- [ ] Disable the built-in Administrator account — use a renamed equivalent
- [ ] Enable **AD Recycle Bin** for object recovery
- [ ] Audit all accounts with `adminCount=1`
- [ ] Review and restrict **delegation settings** — avoid unconstrained delegation

---

## 3. 💻 Windows Endpoints

### Win10 Victim (172.16.0.10) & General Windows

#### INC-007 — PowerShell / Macro Hardening
- [ ] Enable **Script Block Logging**: `HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging → EnableScriptBlockLogging: 1`
- [ ] Enable **Module Logging** and **Transcription**
- [ ] Set PowerShell execution policy to `RemoteSigned` or `AllSigned`
- [ ] Enable **Constrained Language Mode** for non-admin users
- [ ] Disable PowerShell v2: `Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root`
- [ ] Enable **AMSI** — ensure AV/EDR solution integrates with AMSI pipeline
- [ ] Disable Office macros via GPO or restrict to signed macros only

#### Attack Surface Reduction (ASR) Rules
```powershell
# Enable key ASR rules via PowerShell (requires Defender)
Add-MpPreference -AttackSurfaceReductionRules_Ids `
  75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 `  # Block Office from creating child processes
  -AttackSurfaceReductionRules_Actions Enabled
```

#### General Endpoint Hardening
- [ ] Enable Windows Defender with real-time protection (or EDR)
- [ ] Enable **Windows Firewall** on all profiles — log dropped packets
- [ ] Disable unnecessary services: Telnet, FTP, Remote Registry, WMI (where not needed)
- [ ] Enable **LSA Protection**: `HKLM\SYSTEM\CurrentControlSet\Control\Lsa → RunAsPPL: 1`
- [ ] Enable **Credential Guard** via Device Guard policy
- [ ] Patch regularly — especially MS-NRPC, Zerologon-class vulns on DC

---

## 4. 🐧 Ubuntu Victim (172.16.0.20)

- [ ] **Fix Filebeat output** — currently `output.elasticsearch` is commented out; confirm destination and restart
- [ ] Disable root SSH login: `PermitRootLogin no` in `/etc/ssh/sshd_config`
- [ ] Use SSH keys only — disable password authentication
- [ ] Enable UFW firewall: `ufw enable` — allow only necessary ports
- [ ] Enable `auditd` for syscall logging: `apt install auditd audispd-plugins`
- [ ] Ship `auditd` logs to ELK via Filebeat `auditd` module
- [ ] Restrict sudo: use `sudoers` with specific command allowances, not blanket `ALL`
- [ ] Enable automatic security updates: `unattended-upgrades`

---

## 5. 📊 ELK Stack (172.16.0.4)

- [ ] **Change default elastic password** — if still using default, rotate immediately
- [ ] Enable TLS on all Elasticsearch/Kibana interfaces (already done ✅)
- [ ] Restrict Kibana to management VLAN only — not accessible from Kali VLAN
- [ ] Enable **Elasticsearch security features** — role-based access control
- [ ] Create a **read-only SOC analyst role** in Kibana — don't use elastic superuser for daily work
- [ ] Set **index lifecycle management (ILM)** — prevent disk exhaustion from log growth
- [ ] Enable **alerting** in Kibana for Sigma rule detections
- [ ] Back up ELK snapshots before each major scenario run
- [ ] Audit Logstash pipelines — ensure no sensitive data (passwords, hashes) is stored in plain text in indices

---

## 6. 🔬 FLARE-VM (172.16.0.30)

- [x] Outbound internet blocked by pfSense ✅
- [x] No telemetry — intentional for malware analysis ✅
- [ ] Use **snapshots** religiously — revert before every malware detonation
- [ ] Never paste credentials from other VMs into FLARE-VM
- [ ] Use a **dedicated isolated network adapter** for malware C2 simulation — not the main lab network
- [ ] Disable shared clipboard between host and FLARE-VM unless explicitly needed
- [ ] Document installed tool inventory in `infrastructure/flare-vm.md`

---

## 7. ⚔️ Kali Attacker Opsec (172.16.0.11)

> Even in a lab, practicing attacker opsec builds muscle memory for real engagements.

- [ ] Use a **dedicated terminal per scenario** — avoid mixing attack output across sessions
- [ ] Log all commands: `script ~/logs/INC-002-$(date +%Y%m%d).log`
- [ ] Never store real credentials or hashes in plaintext files — use `~/.local/share/` with restricted permissions
- [ ] Clear Impacket's credential cache after each scenario: `rm -f ~/.impacket*`
- [ ] Use `tmux` sessions named per scenario for clean session management
- [ ] Keep Impacket and tooling updated: `pip install --upgrade impacket`

---

## 8. 📡 Telemetry Hardening (Winlogbeat / Filebeat / Sysmon)

- [ ] Confirm `winlogbeat-*` index is receiving data — verify after every DC reboot
- [ ] Winlogbeat config path: `C:\winlogbeat\winlogbeat.yml` — not the default path, document for all team members
- [ ] Ensure Winlogbeat ships **Security**, **Sysmon**, **PowerShell**, and **System** channels
- [ ] Set Winlogbeat to auto-start on boot: `Set-Service winlogbeat -StartupType Automatic`
- [ ] Fix Ubuntu Filebeat output (`output.elasticsearch` currently commented out)
- [ ] Verify `filebeat-*` index exists and receives data
- [ ] Use **Logstash pipelines** to enrich and route events by source type
- [ ] Back up all agent configs to this repo before making live changes

---

## 9. 🔐 Credential Hygiene (Lab-Wide)

> This section applies to YOU as the lab operator.

- [ ] **Never commit real passwords or hashes to GitHub** — use `<REDACTED>` placeholders in docs
- [ ] Use different passwords for every lab VM — no password reuse across lab and personal accounts
- [ ] Store lab credentials in a local password manager (KeePass, Bitwarden local vault)
- [ ] Label all deliberately weak accounts clearly in AD description field: `"LAB ACCOUNT — DO NOT USE IN PRODUCTION"`
- [ ] Rotate all lab passwords after sharing any writeup or repo publicly
- [ ] Use `.gitignore` to exclude any files that might contain credentials: `*.env`, `secrets.yml`, `creds.txt`

---

## Hardening Progress Tracker

| Component | Hardened | Notes |
|-----------|----------|-------|
| pfSense firewall rules | 🟡 Partial | Basic rules in place, not fully documented |
| VLAN segmentation | ❌ Planned | Scheduled for v2.1 |
| AD — PreAuth enforcement | ❌ Lab intentional | svc_asrep left vulnerable for INC-002 |
| AD — RC4 disabled | ❌ Lab intentional | Required for INC-002/003 demos |
| AD — gMSA for services | ❌ TODO | |
| Windows endpoints — LSA Protection | ❌ TODO | |
| Windows endpoints — Credential Guard | ❌ TODO | |
| ELK — RBAC enabled | ❌ TODO | |
| ELK — ILM configured | ❌ TODO | |
| Ubuntu — Filebeat output fixed | ❌ TODO | |
| Suricata on pfSense | ❌ TODO | |
| Kali — command logging | ❌ TODO | |
