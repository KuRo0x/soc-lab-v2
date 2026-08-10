# 💻 Windows 10 — Victim VM

## Host
- **IP:** 172.16.0.10
- **OS:** Windows 10
- **Domain:** `soc.lab`

## Status
- [x] Network connectivity — assumed OK (TODO: verify)
- [ ] **Sysmon — not yet verified** ⚠️
- [ ] **Winlogbeat — not yet verified** ⚠️
- [ ] Domain-joined to `soc.lab` — not yet confirmed

## Verification Commands (run on Win10, PowerShell as Admin)
```powershell
# Network
ipconfig /all
ping 172.16.0.5 -n 4
ping 172.16.0.4 -n 4

# Sysmon
Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue

# Winlogbeat
Get-Service -Name winlogbeat -ErrorAction SilentlyContinue
Get-Content "C:\ProgramData\winlogbeat\winlogbeat.yml" | Select-String "output"

# Domain join check
(Get-WmiObject Win32_ComputerSystem).Domain
```

## TODO
- [ ] Run verification commands above
- [ ] Confirm Sysmon config matches DC (SwiftOnSecurity v4.90)
- [ ] Confirm Winlogbeat shipping to ELK
- [ ] Confirm domain join
