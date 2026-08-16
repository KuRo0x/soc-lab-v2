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
- [x] Audit policy — verified 2026-08-16 (see below)
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

---

## 📋 Audit Policy — Full Output (verified 2026-08-16)

> Run: `auditpol /get /category:*` on SOC-Lab-DC as Administrator

### System
| Subcategory | Setting |
|---|---|
| Security System Extension | No Auditing |
| System Integrity | Success and Failure |
| IPsec Driver | No Auditing |
| Other System Events | Success and Failure |
| Security State Change | Success |

### Logon/Logoff
| Subcategory | Setting |
|---|---|
| Logon | **Success and Failure** ✅ |
| Logoff | Success |
| Account Lockout | Success and Failure |
| Special Logon | Success and Failure |
| Other Logon/Logoff Events | ❌ No Auditing — **needs fix for INC-004** |
| Group Membership | No Auditing |
| Network Policy Server | Success and Failure |

### Object Access
| Subcategory | Setting |
|---|---|
| File System | No Auditing |
| SAM | No Auditing |
| File Share | No Auditing |
| *(all others)* | No Auditing |

### Privilege Use
| Subcategory | Setting |
|---|---|
| Sensitive Privilege Use | **Success and Failure** ✅ |
| Non Sensitive Privilege Use | No Auditing |

### Detailed Tracking
| Subcategory | Setting |
|---|---|
| Process Creation | ❌ No Auditing — Sysmon EID 1 covers this, not a real gap |
| *(all others)* | No Auditing |

### Policy Change
| Subcategory | Setting |
|---|---|
| Audit Policy Change | Success |
| Authentication Policy Change | Success |
| *(all others)* | No Auditing |

### Account Management
| Subcategory | Setting |
|---|---|
| User Account Management | Success |
| Computer Account Management | Success |
| Security Group Management | Success |

### DS Access
| Subcategory | Setting |
|---|---|
| Directory Service Access | **Success and Failure** ✅ |
| Directory Service Changes | **Success and Failure** ✅ |
| Directory Service Replication | ❌ No Auditing — **needs fix for INC-005 DCSync (EID 4929)** |
| Detailed Directory Service Replication | ❌ No Auditing — **needs fix for INC-005 DCSync (EID 4662)** |

### Account Logon
| Subcategory | Setting |
|---|---|
| Kerberos Authentication Service | **Success and Failure** ✅ — EID 4768 |
| Kerberos Service Ticket Operations | **Success and Failure** ✅ — EID 4769 |
| Credential Validation | **Success and Failure** ✅ — EID 4776 |
| Other Account Logon Events | No Auditing |

---

## 🎯 Per-Incident Audit Readiness

| Incident | Key Event IDs | Audit Status | Ready? |
|---|---|---|---|
| INC-002 AS-REP Roasting | 4768 | Kerberos Auth: S+F ✅ | ✅ DONE |
| INC-003 Kerberoasting | 4769 | Kerberos Ticket Ops: S+F ✅ | ✅ READY |
| INC-004 Pass-the-Hash | 4624, 4648, 4776 | Logon: S+F ✅, Cred Validation: S+F ✅, Other Logon/Logoff: ❌ | ⚠️ PARTIAL |
| INC-005 DCSync | 4662, 4929 | DS Access: S+F ✅, DS Replication: ❌ | ❌ NOT READY |

---

## 🔧 Commands to Fix Missing Policies

Run on DC as Administrator **before starting INC-004 / INC-005:**

```cmd
:: INC-004 — capture explicit credential logons (Event 4648)
auditpol /set /subcategory:"Other Logon/Logoff Events" /success:enable /failure:enable

:: INC-005 — capture DCSync replication events (Events 4662, 4929)
auditpol /set /subcategory:"Directory Service Replication" /success:enable /failure:enable
auditpol /set /subcategory:"Detailed Directory Service Replication" /success:enable /failure:enable
```

> **Note:** Process Creation is No Auditing natively, but Sysmon EID 1 covers process creation on this host — not a gap for current scenarios.
