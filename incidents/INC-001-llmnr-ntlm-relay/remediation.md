# INC-001 — Remediation

## Root Cause

LLMNR and NBT-NS were enabled on Win10 with no GPO restriction. The DC’s LDAP signing was set to `Negotiate` instead of `Required`, allowing an unauthenticated relay from any LAN host. An attacker with LAN access could silently intercept any failed name resolution and relay the resulting credential to LDAP to escalate privileges.

---

## Fix 1 — Disable LLMNR via GPO (Highest Priority)

LLMNR is the root enabler of this attack. Disabling it removes the poisoning vector entirely.

```
GPO path:
Computer Configuration
  └ Administrative Templates
      └ Network
          └ DNS Client
              └ Turn off multicast name resolution → Enabled
```

Apply to all domain-joined workstations and servers.

---

## Fix 2 — Disable NBT-NS

NBT-NS is the legacy fallback after LLMNR. Disable it on all hosts.

```
NIC properties → Internet Protocol Version 4 (TCP/IPv4) → Advanced
  └ WINS tab → Disable NetBIOS over TCP/IP
```

Or via registry (deploy via GPO):
```reg
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_{GUID}]
"NetbiosOptions"=dword:00000002
```

---

## Fix 3 — Require LDAP Signing on DC

Prevents unauthenticated LDAP relay. Without this, any captured NTLMv2 credential can be relayed to LDAP.

```
GPO path:
Computer Configuration
  └ Windows Settings
      └ Security Settings
          └ Local Policies
              └ Security Options
                  └ Domain controller: LDAP server signing requirements → Require signing
```

---

## Fix 4 — Enable SMB Signing on All Hosts

Prevents the SMB relay variant of this attack.

```
GPO path:
Computer Configuration
  └ Windows Settings
      └ Security Settings
          └ Local Policies
              └ Security Options
                  └ Microsoft network server: Digitally sign communications (always) → Enabled
                  └ Microsoft network client: Digitally sign communications (always) → Enabled
```

---

## Fix 5 — Enable Extended Protection for Authentication (EPA)

EPA binds NTLM authentication to the TLS channel, preventing relay to HTTPS/LDAPS endpoints even if credentials are captured.

Enable on IIS and LDAP services. Requires patching and configuration — test in staging before deploying to production.

---

## Detection Hardening

| Action | Details |
|--------|---------|
| Alert on EID 4662 ObjectServer:DS | Any WRITE_DAC or Write Property on domain object outside maintenance window |
| Alert on EID 4624 LogonType 3 NTLM from unknown IPs | Unexpected network logons using NTLM |
| Monitor LLMNR/MDNS traffic on LAN | Suricata ET rules — multicast responses from non-DC hosts |
| Periodic AD ACL audit | Alert on unexpected `Replication-Get-Changes-All` grant |

---

## Priority Order

1. 🔴 Disable LLMNR via GPO — eliminates the attack vector entirely
2. 🔴 Require LDAP signing on DC — blocks the relay even if LLMNR is still active
3. 🟡 Disable NBT-NS — removes legacy fallback
4. 🟡 Enable SMB signing everywhere — blocks SMB relay variant
5. 🟢 EPA — defence-in-depth, more complex to deploy
