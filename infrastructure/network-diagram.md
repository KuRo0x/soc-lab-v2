# 🌐 Network Topology

## Subnet: `172.16.0.0/24`

```
                        [Internet]
                            |
                      [pfSense]
                    172.16.0.1 (Gateway/Firewall)
                            |
              ——————————————————————————————————
              |         |         |            |
          [ELK SIEM]  [DC]    [Win10]       [Kali]
          172.16.0.4  172.16.0.5  172.16.0.10  172.16.0.11
                            |
              ——————————————————————————————
              |                            |
         [Ubuntu Victim]             [FLARE-VM]
          172.16.0.20               172.16.0.30
                                   (ISOLATED — outbound blocked)
```

## IP Assignments

| Hostname | IP | Role | OS |
|----------|----|------|----|
| pfSense | 172.16.0.1 | Firewall / Gateway | pfSense CE |
| ELK | 172.16.0.4 | SIEM | Ubuntu 22.04 |
| DC | 172.16.0.5 | Domain Controller | Windows Server 2019 |
| Win10 | 172.16.0.10 | Victim (Windows) | Windows 10 |
| Kali | 172.16.0.11 | Attacker | Kali Linux |
| Ubuntu Victim | 172.16.0.20 | Victim (Linux) | Ubuntu 22.04 |
| FLARE-VM | 172.16.0.30 | Malware Analysis | Windows 10 + FLARE |

## Firewall Rules (pfSense — LAN)

| Rule | Source | Destination | Action | Note |
|------|--------|-------------|--------|------|
| BLOCK-FLARE-VM-OUTBOUND | 172.16.0.30 | Any | Block | Isolates FLARE-VM |
| Default LAN → WAN | LAN net | Any | Allow | Standard outbound |

> Full rule export: TODO — export from pfSense UI and paste here
