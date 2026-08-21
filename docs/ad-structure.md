# Active Directory Structure — SOC.LAB

> Domain: `SOC.LAB` (`soc.lab`)  
> Domain Controller: `SOC-Lab-DC` / `172.16.0.5`  
> Last updated: 2026-08-21

---

## Users

| Name | SamAccountName | Enabled | Notes |
|------|---------------|---------|-------|
| Administrator | Administrator | ✅ | Built-in domain admin |
| Guest | Guest | ❌ | Built-in guest, disabled |
| krbtgt | krbtgt | ❌ | Kerberos TGT account, disabled by default |
| svc_asrep | svc_asrep | ✅ | Lab service account — `DoesNotRequirePreAuth=true` (INC-002) |
| svc_http | svc_http | ✅ | Lab service account — SPN `HTTP/soc-lab-dc.soc.lab` set (INC-003) |

> ⚠️ `svc_asrep` and `svc_http` are intentionally vulnerable accounts created for lab scenarios. Do not use in production.

---

## Groups

### Built-in / Default Groups

| Name | Notes |
|------|-------|
| Administrators | Full admin rights on domain |
| Domain Admins | Domain-wide admin privileges |
| Domain Users | All domain users (default) |
| Domain Guests | Guest accounts |
| Domain Computers | All domain-joined machines |
| Domain Controllers | All DCs in the domain |
| Schema Admins | Can modify AD schema |
| Enterprise Admins | Forest-wide admin rights |
| Group Policy Creator Owners | Can create/modify GPOs |
| Protected Users | High-value accounts with Kerberos protections |
| krbtgt | Kerberos service account |
| DnsAdmins | DNS administration |
| DnsUpdateProxy | DNS dynamic update proxy |
| Cert Publishers | Can publish certificates to AD |
| RAS and IAS Servers | Remote access / RADIUS servers |
| Read-only Domain Controllers | RODC accounts |
| Cloneable Domain Controllers | DCs eligible for cloning |
| Key Admins / Enterprise Key Admins | Manage DPAPI / credential keys |
| Remote Desktop Users | RDP access |
| Remote Management Users | WinRM / PSRemoting access |
| Print Operators | Manage printers on DCs |
| Backup Operators | Backup/restore rights |
| Account Operators | Manage non-admin accounts |
| Server Operators | Manage domain servers |
| Replicator | Directory replication service |
| Network Configuration Operators | Manage network settings |
| Performance Monitor Users | Read performance counters |
| Performance Log Users | Log performance data |
| Event Log Readers | Read event logs |
| IIS_IUSRS | IIS worker process accounts |
| Cryptographic Operators | Perform crypto operations |
| Distributed COM Users | Activate/launch DCOM objects |
| Hyper-V Administrators | Full Hyper-V access |
| Access Control Assistance Operators | Remotely query access for resources |
| Storage Replica Administrators | Manage Storage Replica |
| Certificate Service DCOM Access | Connect to CA DCOM |
| RDS Remote Access Servers / Endpoint / Management | RDS infrastructure groups |
| Pre-Windows 2000 Compatible Access | Legacy pre-auth compatibility |
| Incoming Forest Trust Builders | Create forest trusts |
| Windows Authorization Access Group | Access tokenGroupsGlobalAndUniversal |
| Terminal Server License Servers | License server access |
| Allowed / Denied RODC Password Replication Group | RODC password caching policy |
| Enterprise Read-only Domain Controllers | Enterprise RODC accounts |

---

## Organisational Units (OUs)

| Name | Distinguished Name |
|------|-------------------|
| Domain Controllers | `OU=Domain Controllers,DC=soc,DC=lab` |

> Only the default `Domain Controllers` OU exists. All lab user and service accounts sit directly in the default `CN=Users,DC=soc,DC=lab` container. OUs for user/service account segmentation are planned for a future lab iteration.

---

## Lab-Created Accounts Summary

| Account | Purpose | Vulnerability | Incident |
|---------|---------|--------------|----------|
| `svc_asrep` | Simulated service account | `DoesNotRequirePreAuth = true` | [INC-002](../incidents/INC-002-asrep-roasting/README.md) |
| `svc_http` | Simulated web service account | SPN set, RC4 allowed | [INC-003](../incidents/INC-003-kerberoasting/README.md) |

---

## Useful Audit Commands

```powershell
# List all users
Get-ADUser -Filter * -Properties DisplayName,MemberOf | Select Name,SamAccountName,Enabled

# Find AS-REP roastable accounts
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth

# Find Kerberoastable accounts (SPN set)
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName

# List all groups
Get-ADGroup -Filter * | Select Name,GroupScope,GroupCategory

# List all OUs
Get-ADOrganizationalUnit -Filter * | Select Name,DistinguishedName
```
