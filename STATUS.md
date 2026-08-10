# 📊 Lab Status — What's Done & What's Missing

> Last updated: 2026-08-11  
> Use this file as your single source of truth. Update it every time you make a change.

---

## ✅ Verified & Done

### Infrastructure
- [x] **pfSense** (172.16.0.1) — Firewall up, LAN rules configured, FLARE-VM outbound blocked
- [x] **ELK Stack** (172.16.0.4) — Elasticsearch + Kibana running, TLS enabled
- [x] **Domain Controller** (172.16.0.5) — AD `soc.lab` healthy, DNS working
- [x] **Kali Linux** (172.16.0.11) — Network OK, Impacket + Nmap + Responder installed
- [x] **Windows 10 Victim** (172.16.0.10) — Network OK
- [x] **Ubuntu Victim** (172.16.0.20) — Network OK, Filebeat running
- [x] **FLARE-VM** (172.16.0.30) — Network OK (reaches DC + ELK directly), pfSense outbound block in place

### Telemetry / Log Shipping
- [x] **DC → ELK** — Sysmon (SwiftOnSecurity v4.90) + Winlogbeat installed and running
- [x] **Ubuntu Victim → ELK** — Filebeat running
- [ ] **Win10 Victim → ELK** — Winlogbeat status not yet verified ⚠️
- [ ] **Kali → ELK** — No log shipping (intentional? confirm)
- [x] **FLARE-VM** — No telemetry by design (isolated malware analysis)

### Security Tools (Kali)
- [x] Impacket (`impacket-GetNPUsers`)
- [x] Nmap
- [x] Responder
- [ ] BloodHound — **NOT installed** ❌
- [ ] CrackMapExec — not verified
- [ ] Metasploit — not verified

---

## ❌ Missing / TODO

### High Priority
- [ ] **BloodHound on Kali** — install with `sudo apt install bloodhound -y`
- [ ] **Win10 Victim** — verify Sysmon + Winlogbeat installed and shipping to ELK
- [ ] **ELK Dashboards** — confirm Kibana dashboards exist for Windows + Linux events
- [ ] **ELK Index verification** — confirm `winlogbeat-*` and `filebeat-*` indices receiving data
- [ ] **Filebeat config on Ubuntu** — `output.elasticsearch` is commented out; verify correct output (Logstash? or direct ES?)

### Medium Priority
- [ ] **pfSense firewall rules** — document all current rules in `infrastructure/pfsense.md`
- [ ] **Logstash pipeline** — save current pipeline config to `configs/elk/logstash-pipeline.conf`
- [ ] **AD users/OUs** — document AD structure (users, groups, OUs) in `infrastructure/dc.md`
- [ ] **GPO configuration** — document GPOs applied in AD
- [ ] **Kibana alerting rules** — document any detection rules in Kibana

### Low Priority / Nice to Have
- [ ] **Network diagram** (visual) — add to `infrastructure/network-diagram.md`
- [ ] **FLARE-VM tool inventory** — list installed tools (Ghidra, x64dbg, etc.) in `infrastructure/flare-vm.md`
- [ ] **Attack scenario scripts** — add to `scenarios/`
- [ ] **IR playbook templates** — expand `playbooks/` with full detection + response steps
- [ ] **Snort/Suricata on pfSense** — IDS/IPS not yet configured
- [ ] **Velociraptor or Wazuh** — consider adding for host-based detection

---

## 🔍 Needs Investigation

| Item | Question | Action |
|------|----------|--------|
| Ubuntu Filebeat | `output.elasticsearch` is commented out — where are logs going? | Check `/etc/filebeat/filebeat.yml` full output section |
| Win10 Victim | Sysmon + Winlogbeat status unknown | Run verification commands (see `infrastructure/win10-victim.md`) |
| Kali tools | CrackMapExec, Metasploit not verified | Run `which crackmapexec` and `which msfconsole` |
| ELK indices | No confirmation that data is flowing into ES | Run `curl -k -u elastic:PASS https://172.16.0.4:9200/_cat/indices?v` |
| pfSense rules | Full ruleset not documented | Export rules from pfSense UI |
