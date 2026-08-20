# pfSense Firewall Rules — soc-lab-v2

> **Source:** Manually documented from pfSense Web UI (172.16.0.1)  
> **TODO:** Export full XML backup via Diagnostics > Backup/Restore

---

## LAN Interface Rules

| Priority | Rule Name | Source | Destination | Port | Protocol | Action | Notes |
|----------|-----------|--------|-------------|------|----------|--------|-------|
| 1 | BLOCK-FLARE-VM-OUTBOUND | 172.16.0.30 | any | any | any | **Block** | FLARE-VM is isolated — no outbound except to ELK |
| 2 | ALLOW-FLARE-TO-ELK | 172.16.0.30 | 172.16.0.4 | 9200, 5601 | TCP | Allow | FLARE-VM → ELK only |
| 3 | ALLOW-KALI-INTERNAL | 172.16.0.11 | 172.16.0.0/24 | any | any | Allow | Kali attacker — internal only |
| 4 | Default LAN | LAN net | any | any | any | Allow | Catch-all for lab traffic |

---

## DHCP Static Mappings

| Hostname | MAC | IP | Notes |
|----------|-----|----|-------|
| dc01 | _pending_ | 172.16.0.5 | Domain Controller |
| elk | _pending_ | 172.16.0.4 | ELK Stack |
| kali | _pending_ | 172.16.0.11 | Attacker VM |
| flare-vm | _pending_ | 172.16.0.30 | Malware Analysis |
| ubuntu-victim | _pending_ | 172.16.0.20 | Linux Victim |
| win10-victim | _pending_ | 172.16.0.10 | Windows Victim |

> ⚠️ MAC addresses not yet recorded — run `arp -a` on pfSense to populate.

---

## DNS Resolver

- **Resolver:** Unbound (default)
- **Domain:** `lab.local`
- **Upstream DNS:** 8.8.8.8, 1.1.1.1
- **Local overrides:** _none documented yet_

---

## TODO
- [ ] Export full pfSense XML backup (Diagnostics > Backup/Restore > Download)
- [ ] Record MAC addresses for all DHCP static mappings
- [ ] Document DNS resolver host overrides
- [ ] Design VLAN segmentation for v2.1 (attacker / victim / management)
