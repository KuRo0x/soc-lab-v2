# 🏛️ Domain Controller

## Host
- **IP:** 172.16.0.5
- **Hostname:** DC01 (or as configured)
- **OS:** Windows Server 2019
- **Domain:** `soc.lab`

## Status
- [x] AD Domain `soc.lab` — healthy
- [x] DNS — working (resolves internally)
- [x] Sysmon — installed, SwiftOnSecurity v4.90 config
- [x] Winlogbeat — installed and running, shipping to ELK
- [ ] AD Users/OUs documented — TODO
- [ ] GPO configuration documented — TODO

## AD Structure (TODO)
> Document your OUs, users, and groups here.

```
Domain: soc.lab
├── Users/
│   ├── Administrator
│   └── [TODO: add lab users]
├── Computers/
│   └── [TODO: list joined machines]
└── Groups/
    └── [TODO: list groups]
```

## Telemetry
- **Sysmon config:** SwiftOnSecurity sysmon-modular v4.90
- **Winlogbeat output:** ELK (172.16.0.4:9200 or 5044)
- **Index:** `winlogbeat-*`
