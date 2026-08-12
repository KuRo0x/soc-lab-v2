# 🏛️ Domain Controller

## Host
- **IP:** 172.16.0.5
- **Hostname:** `SOC-Lab-DC` (FQDN: `SOC-Lab-DC.soc.lab`)
- **OS:** Windows Server 2022 Standard Evaluation (Build 20348.587)
- **Domain:** `soc.lab`

## Status
- [x] AD Domain `soc.lab` — healthy
- [x] DNS — working (resolves internally)
- [x] Sysmon — installed, sysmon-modular v4.90 (Olaf Hartong config)
- [x] Winlogbeat — installed at `C:\winlogbeat\` (non-default path), shipping to ELK
- [x] Winlogbeat ships: Security, Sysmon, PowerShell, System, ForwardedEvents
- [ ] AD Users/OUs documented — TODO
- [ ] GPO configuration documented — TODO

## AD Structure

```
Domain: soc.lab
├── Users/
│   ├── Administrator
│   └── svc_asrep  ← INC-002 vulnerable account (DoesNotRequirePreAuth=true)
├── Computers/
│   ├── SOC-Lab-DC
│   └── SOC-Lab-Endpoint (172.16.0.10, domain-joined)
└── Groups/
    └── [TODO: document groups]
```

## Winlogbeat
- **Install path:** `C:\winlogbeat\winlogbeat.yml` (not default `C:\Program Files\Winlogbeat\`)
- **Version:** 8.17.0
- **Output:** Elasticsearch at 172.16.0.4:9200 (TLS)
- **Index:** `winlogbeat-YYYY.MM.DD`
- **Channels shipped:** Application, System, Security, Microsoft-Windows-Sysmon/Operational, Windows PowerShell, Microsoft-Windows-PowerShell/Operational, ForwardedEvents

## Telemetry
- **Sysmon config:** sysmon-modular v4.90 (Olaf Hartong)
- **Winlogbeat output:** ELK (172.16.0.4)
- **Confirmed indices:** `winlogbeat-2026.08.12` ✅

## Lab Accounts

| Account | Purpose | Security Note |
|---------|---------|---------------|
| Administrator | Domain admin | Lab use only |
| svc_asrep | INC-002 AS-REP Roasting target | **Intentionally vulnerable** — DoesNotRequirePreAuth=true, weak password. Lab only. |
