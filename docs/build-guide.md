# 🔧 Build Guide — SOC Lab v2

> Step-by-step lab deployment. Follow in order.

## Prerequisites
- Hypervisor: VMware Workstation Pro (or ESXi / Proxmox)
- Host RAM: 32GB minimum recommended
- Host Storage: 500GB minimum
- ISOs needed: pfSense CE, Ubuntu 22.04, Windows Server 2019, Windows 10, Kali Linux

---

## Step 1 — pfSense (172.16.0.1)
1. Create VM, attach pfSense CE ISO
2. Install — assign WAN (NAT/bridged) and LAN (host-only 172.16.0.0/24)
3. Set LAN IP: `172.16.0.1/24`
4. Enable static IPs per VM (or configure DHCP reservations)
5. Add firewall rule: Block all outbound from `172.16.0.30` (FLARE-VM isolation)
6. Web UI: `https://172.16.0.1`

---

## Step 2 — ELK SIEM (172.16.0.4)
```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update && sudo apt install elasticsearch kibana logstash -y
sudo systemctl enable --now elasticsearch kibana logstash
```
- Configure Elasticsearch for HTTPS, set `elastic` password
- Kibana: `https://172.16.0.4:5601`

---

## Step 3 — Domain Controller (172.16.0.5)
1. Install Windows Server 2019, static IP `172.16.0.5`
2. Promote to DC, create domain `soc.lab`
3. Install Sysmon:
```powershell
New-Item -Path C:\Sysmon -ItemType Directory -Force
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile C:\Sysmon\Sysmon.zip
Expand-Archive C:\Sysmon\Sysmon.zip -DestinationPath C:\Sysmon -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml" -OutFile C:\Sysmon\sysmonconfig.xml
C:\Sysmon\Sysmon64.exe -accepteula -i C:\Sysmon\sysmonconfig.xml
```
4. Install Winlogbeat, configure output to ELK
5. Verify: `Get-Service Sysmon64, winlogbeat`

---

## Step 4 — Windows 10 Victim (172.16.0.10)
1. Static IP `172.16.0.10`, join to `soc.lab`
2. Install Sysmon (same config as DC)
3. Install Winlogbeat
4. Verify telemetry flowing to ELK

---

## Step 5 — Kali Linux (172.16.0.11)
```bash
sudo apt update
sudo apt install bloodhound crackmapexec evil-winrm -y
which nmap responder impacket-GetNPUsers bloodhound crackmapexec
```

---

## Step 6 — Ubuntu Victim (172.16.0.20)
```bash
sudo apt install filebeat -y
sudo systemctl enable --now filebeat
# Edit /etc/filebeat/filebeat.yml — set output.elasticsearch to 172.16.0.4:9200
sudo filebeat test output
```

---

## Step 7 — FLARE-VM (172.16.0.30)
1. Static IP `172.16.0.30`
2. Install FLARE-VM toolkit: https://github.com/mandiant/flare-vm
3. **Do NOT install Sysmon or Winlogbeat** — malware analysis VM, no telemetry
4. Confirm pfSense block rule is in place for `172.16.0.30`
5. Take clean snapshot before any malware work

---

## Verification Checklist
- [ ] All VMs ping each other (except FLARE-VM outbound to WAN)
- [ ] `soc.lab` domain healthy
- [ ] `winlogbeat-*` index in Kibana
- [ ] `filebeat-*` index in Kibana
- [ ] Sysmon Event ID 1, 3, 10 visible in Kibana
