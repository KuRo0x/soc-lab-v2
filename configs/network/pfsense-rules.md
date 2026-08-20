# pfSense Firewall Rules — soc-lab-v2

> **Source:** Verified from pfSense Web UI (172.16.0.1) — Firewall > Rules > LAN  
> **Verified:** 2026-08-20  
> **Interface:** LAN  

---

## ✅ Live LAN Rules (Verified from UI)

| # | State | Protocol | Source | Destination | Port | Description |
|---|-------|----------|--------|-------------|------|-------------|
| 1 | ✅ Enabled | * | * | LAN Address | 443, 80 | Anti-Lockout Rule (pfSense auto-generated) |
| 2 | ❌ Disabled | IPv4 * | 172.16.0.30 | * | * | BLOCK-FLARE-VM-OUTBOUND |
| 3 | ✅ Enabled | IPv4 * | LAN subnets | * | * | Default allow LAN to any rule |
| 4 | ✅ Enabled | IPv6 * | LAN subnets | * | * | Default allow LAN IPv6 to any rule |

> **Note:** Rule 2 (BLOCK-FLARE-VM) shows 0/0 B — no traffic has hit it yet (FLARE-VM not active).  
> **Note:** Rule 3 has passed 33/410.19 MiB — this is carrying all lab traffic.  
> ⚠️ **WARNING:** pfSense admin password is still set to default (`pfsense`) — change immediately.

---

## ⚠️ Current Security Finding — Flat Network

**Rule 3 (Default allow LAN to any) is too permissive for a production environment.**

With this rule active, every host on `172.16.0.0/24` — including the attacker VM Kali (`172.16.0.11`) — can reach the Domain Controller (`172.16.0.5`) on any port. This is what enabled:

| Incident | Attack Path | Enabled by Rule 3 |
|----------|-------------|-------------------|
| INC-001 | LLMNR Poisoning — Kali listens on LAN | ✅ |
| INC-002 | AS-REP Roasting — Kali → DC port 88 | ✅ |
| INC-003 | Kerberoasting — Kali → DC port 88 | ✅ |
| INC-004 | Pass-the-Hash — Kali → DC port 445 | ✅ |
| INC-005 | DCSync — Kali → DC port 389/445 | ✅ |

> This is **intentional for the lab** so all attack scenarios can run.  
> In a real enterprise this configuration would be a critical finding.

---

## 🏭 Production Hardening — What Rule 3 Should Become

In a real enterprise following **Microsoft AD Tier Model** and **CIS Benchmarks**, the DC should only be reachable from authorised hosts on required ports. Replace rule 3 with:

| Priority | Action | Source | Destination | Ports | Protocol | Description |
|----------|--------|--------|-------------|-------|----------|-------------|
| 3a | **ALLOW** | 172.16.0.10 (Win10) | 172.16.0.5 (DC) | 88, 389, 445, 636, 3268, 3269 | TCP | Domain-joined workstation → DC (Kerberos, LDAP, SMB) |
| 3b | **ALLOW** | 172.16.0.4 (ELK) | 172.16.0.5 (DC) | 389, 636 | TCP | ELK LDAP auth if needed |
| 3c | **ALLOW** | * | 172.16.0.5 (DC) | 53 | UDP/TCP | DNS — all hosts need DNS resolution |
| 3d | **BLOCK** | 172.16.0.11 (Kali) | 172.16.0.5 (DC) | any | any | BLOCK-KALI-TO-DC — attacker cannot reach DC |
| 3e | **BLOCK** | * | 172.16.0.5 (DC) | any | any | BLOCK-ALL-TO-DC — default deny to DC |
| 3f | **ALLOW** | LAN subnets | * | any | any | Default allow for non-DC traffic |

**What this achieves:**
- Kali (`172.16.0.11`) **cannot perform** Kerberoasting, DCSync, Pass-the-Hash, or AS-REP Roasting
- Win10 victim can still function as a normal domain member
- All hosts still have internet/LAN access for non-AD traffic
- ELK stack can still collect logs

**Real enterprise references:**
- Microsoft AD Tier Model — DC is Tier 0, only Tier 0 admin workstations reach it directly
- CIS Benchmark for Windows Server — restrict ports 88/389/445 to DC from non-domain systems
- NIST 800-171 — network segmentation as baseline control (3.13.1, 3.13.3)

---

## DHCP Static Mappings

| Hostname | IP | Role |
|----------|----|------|
| pfsense | 172.16.0.1 | Firewall / Gateway |
| elk | 172.16.0.4 | ELK Stack (ES + Kibana + Logstash) |
| dc01 | 172.16.0.5 | Domain Controller (soc.lab) |
| win10-victim | 172.16.0.10 | Windows 10 Victim |
| kali | 172.16.0.11 | Attacker VM |
| ubuntu-victim | 172.16.0.20 | Ubuntu Victim (soc-lab-victim) |
| flare-vm | 172.16.0.30 | Malware Analysis (isolated) |

> ⚠️ MAC addresses not yet recorded — run `arp -a` on pfSense shell to populate.

---

## DNS Resolver

- **Resolver:** Unbound (default)
- **Domain:** `soc.lab`
- **Upstream DNS:** 8.8.8.8, 1.1.1.1
- **Local overrides:** none documented yet

---

## TODO
- [ ] **Change pfSense default password** — currently set to `pfsense` (shown as warning in UI)
- [ ] Export full pfSense XML backup (Diagnostics > Backup/Restore > Download) and commit to repo
- [ ] Record MAC addresses for all DHCP static mappings
- [ ] Implement production hardening rules above in v2.1 after all incidents complete
- [ ] Design VLAN segmentation for v2.1 (attacker / victim / management / DC tiers)
