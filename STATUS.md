# 📊 Lab Status — Single Source of Truth

> Last updated: 2026-08-12
> Open this file when you return to the lab. It tells you exactly where you left off.

---

## ✅ Verified & Done

### Infrastructure
- [x] **pfSense** (172.16.0.1) — firewall up, FLARE-VM outbound blocked
- [x] **ELK Stack** (172.16.0.4) — Elasticsearch + Kibana running, TLS enabled
- [x] **DC / AD** (172.16.0.5) — domain `soc.lab` healthy, DNS working
- [x] **Kali** (172.16.0.11) — network OK, Impacket + Nmap + Responder installed
- [x] **Ubuntu Victim** (172.16.0.20) — network OK, Filebeat running
- [x] **FLARE-VM** (172.16.0.30) — network OK, isolated by design, no telemetry

### Telemetry
- [x] DC → ELK: Sysmon (sysmon-modular v4.90, Olaf Hartong) + Winlogbeat running
- [x] Ubuntu → ELK: Filebeat running
- [x] FLARE-VM: No telemetry — intentional (malware analysis VM)

---

## ❌ Missing / TODO

### 🔴 High Priority
- [ ] **Win10 Victim** (172.16.0.10) — Sysmon + Winlogbeat NOT verified
- [ ] **BloodHound on Kali** — not installed (`sudo apt install bloodhound -y`)
- [ ] **Filebeat output on Ubuntu** — `output.elasticsearch` commented out; destination unknown
- [ ] **ELK indices** — `winlogbeat-*` and `filebeat-*` not confirmed receiving data

### 🟡 Medium Priority
- [ ] **pfSense rules** — full ruleset not documented
- [ ] **Logstash pipeline** — current config not saved to repo
- [ ] **AD structure** — users, OUs, groups not documented
- [ ] **Kibana dashboards** — not confirmed or documented
- [ ] **CrackMapExec on Kali** — not verified
- [ ] **Metasploit on Kali** — not verified

### 🟢 Low Priority
- [ ] **FLARE-VM tool inventory** — list installed tools in `infrastructure/flare-vm.md`
- [ ] **Suricata on pfSense** — IDS/IPS not deployed
- [ ] **Network diagram** (visual PNG) — add to `assets/diagrams/`
- [ ] **VLAN segmentation** — flat network; planned for v2.1

---

## ⚠️ Needs Investigation

| Item | Question | Action |
|------|----------|--------|
| Ubuntu Filebeat | Where are logs going? | `sudo filebeat test output` on 172.16.0.20 |
| Win10 Victim | Sysmon + Winlogbeat installed? | See `infrastructure/win10-victim.md` |
| ELK indices | Is data flowing? | `curl -k -u elastic:PASS https://172.16.0.4:9200/_cat/indices?v` |
| Kali tools | CME + Metasploit present? | `which crackmapexec msfconsole` on 172.16.0.11 |

---

## 🎯 Incident Progress

| ID | Name | Status |
|----|------|--------|
| INC-001 | LLMNR Poisoning + NTLM Relay | 🔲 TODO |
| INC-002 | AS-REP Roasting | 🔄 IN PROGRESS |
| INC-003 | Kerberoasting | 🔲 TODO |
| INC-004 | Pass-the-Hash Lateral Movement | 🔲 TODO |
| INC-005 | DCSync Attack | 🔲 TODO |
| INC-006 | Malware Detonation + C2 Beacon | 🔲 TODO |
| INC-007 | Phishing → Macro → PowerShell | 🔲 TODO |

---

## 🧪 INC-002 — AS-REP Roasting Prereqs

> Complete all 4 checks before running the attack. Do not mark done until each is **live-verified**, not just configured.

### Check 1 — Vulnerable AD User
- [ ] Create `svc_asrep` with PreAuth disabled
- [ ] Password must be **wordlist-crackable** (e.g. `Summer2024!`) — hashcat must crack it in demo time
- [ ] Verify: `Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth | Select Name, SamAccountName`

```powershell
New-ADUser -Name "svc_asrep" -SamAccountName "svc_asrep" `
  -UserPrincipalName "svc_asrep@soc.lab" -Enabled $true `
  -AccountPassword (ConvertTo-SecureString "Summer2024!" -AsPlainText -Force) `
  -PasswordNeverExpires $true
Set-ADAccountControl -Identity "svc_asrep" -DoesNotRequirePreAuth $true
```

### Check 2 — Kerberos Audit Policy (Direct Verify)
- [ ] Run `auditpol` directly on DC — do NOT trust GPO alone
- [ ] Both Success and Failure must show **"Enable"**

```cmd
auditpol /get /subcategory:"Kerberos Authentication Service"
```

> Expected output: `Kerberos Authentication Service    Success and Failure`
> If not: `auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable`

### Check 3 — Winlogbeat Security Log → ELK (Live 4768 Confirm)
- [ ] Confirm `winlogbeat.yml` includes `Security` event log channel (not just Sysmon)
- [ ] Restart Winlogbeat after any config change: `Restart-Service winlogbeat`
- [ ] Run the attack once, then verify **Event ID 4768 with EncryptionType 0x17** lands in Kibana
- [ ] Kibana query: `event.code: 4768 AND winlog.event_data.TicketEncryptionType: "0x17"`

> ⚠️ A config file that hasn't been tested is not a confirmed pipeline. Don't mark this done until 4768 is visible in the index.

### Check 4 — Clock Skew (Kerberos Time Sync) ⏱️
- [ ] Kerberos fails silently with >5 min skew — verify before blaming Winlogbeat
- [ ] Run on DC:

```cmd
w32tm /query /status
```

- [ ] Run on Kali:

```bash
timedatectl
# or: ntpdate -q 172.16.0.5
```

> If skew is >2 min, sync Kali: `sudo ntpdate 172.16.0.5`
