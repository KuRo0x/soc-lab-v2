# DHCP Static Mapping — MAC Address Table

> Generated: 2026-08-28 from `arp -a` on pfSense  
> All VMs are VMware guests (`00:0c:29:*` OUI)

---

## LAN Interface (em1) — `172.16.0.0/24`

| Hostname | IP Address | MAC Address | Role | Notes |
|---|---|---|---|---|
| pfSense | 172.16.0.1 | `00:0c:29:12:c0:c0` | Firewall / Gateway | Permanent |
| ELK Stack | 172.16.0.4 | `00:0c:29:a4:d7:0b` | SIEM (Elasticsearch + Kibana + Logstash) | |
| DC / AD | 172.16.0.5 | `00:0c:29:ec:f5:5b` | Domain Controller (`soc.lab`) | |
| Win10 Victim | 172.16.0.10 | `00:0c:29:db:02:50` | Endpoint (Sysmon + Winlogbeat) | |
| Kali | 172.16.0.11 | `00:0c:29:63:e7:66` | Attacker VM | |
| Ubuntu Victim | 172.16.0.20 | `00:0c:29:d2:d3:ea` | Linux endpoint (Filebeat) | |
| FLARE-VM | 172.16.0.30 | — | Malware analysis (isolated) | Not in ARP cache — outbound blocked by firewall |

> **Note:** FLARE-VM (172.16.0.30) did not appear in the ARP table — expected, as it is blocked outbound by pfSense rule `BLOCK-FLARE-VM-OUTBOUND` and had no active traffic at time of capture.

---

## WAN Interface (em0) — NAT / Host-only

| IP Address | MAC Address | Notes |
|---|---|---|
| 192.168.212.2 | `00:50:56:ea:d2:01` | VMware NAT gateway (host) |
| 192.168.212.131 | `00:0c:29:12:c0:b6` | pfSense WAN NIC (permanent) |

---

## Static DHCP Assignments (Recommended)

To lock these IPs permanently, add static DHCP mappings in pfSense:  
**Services → DHCP Server → LAN → Static Mappings**

| Hostname | IP | MAC |
|---|---|---|
| ELK | 172.16.0.4 | `00:0c:29:a4:d7:0b` |
| DC | 172.16.0.5 | `00:0c:29:ec:f5:5b` |
| Win10 | 172.16.0.10 | `00:0c:29:db:02:50` |
| Kali | 172.16.0.11 | `00:0c:29:63:e7:66` |
| Ubuntu | 172.16.0.20 | `00:0c:29:d2:d3:ea` |
