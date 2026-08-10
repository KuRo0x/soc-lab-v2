# Network Configs

Firewall rules, VLAN configs, routing.

## Known pfSense Rules

| Rule | Source | Destination | Action |
|------|--------|-------------|--------|
| BLOCK-FLARE-VM-OUTBOUND | 172.16.0.30 | any | Block |
| Default LAN | LAN net | any | Allow |

## TODO
- [ ] Export full pfSense ruleset (Diagnostics > Backup > XML)
- [ ] Document DHCP static mappings
- [ ] Document DNS resolver config
- [ ] Design VLAN segmentation for v2.1
