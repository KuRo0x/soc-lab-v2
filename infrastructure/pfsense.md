# 🔥 pfSense — Firewall & Gateway

## Host
- **IP:** 172.16.0.1
- **Role:** Firewall, Gateway, DHCP, DNS relay

## Status
- [x] Up and routing LAN traffic
- [x] FLARE-VM outbound blocked (`BLOCK-FLARE-VM-OUTBOUND`)
- [ ] Full ruleset documented — TODO
- [ ] IDS/IPS (Snort or Suricata) — NOT configured ❌

## Known Firewall Rules

| Rule Name | Source | Destination | Protocol | Action |
|-----------|--------|-------------|----------|--------|
| BLOCK-FLARE-VM-OUTBOUND | 172.16.0.30 | any | any | Block |
| Default LAN | LAN net | any | any | Allow |

> TODO: Export full ruleset from pfSense UI (Firewall > Rules > Export) and paste here.

## TODO
- [ ] Export and document all firewall rules
- [ ] Configure Snort or Suricata (IDS/IPS)
- [ ] Document DHCP static mappings
- [ ] Document DNS resolver config
- [ ] Consider VLAN segmentation for lab vs management traffic
