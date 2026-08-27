# INC-005 — Remediation & Hardening

> **Technique:** T1003.006 — DCSync  
> **Severity:** Critical — full domain credential compromise

---

## 🚨 Immediate Response

1. **Identify the account used** — confirm which account triggered EID 4662 (`svc_asrep` in this lab)
2. **Disable the account immediately** in ADUC → right-click → Disable Account
3. **Revoke DCSync rights** — ADUC → domain root → Delegate Control → remove replication permissions from `svc_asrep`
4. **Reset `krbtgt` password twice** — DCSync exposes the `krbtgt` hash; resetting it twice invalidates all existing Kerberos tickets and Golden Tickets
   ```powershell
   # Run on DC — reset krbtgt password
   Set-ADAccountPassword -Identity krbtgt -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "NewPass1!" -Force)
   # Wait 10 minutes (replication), then reset again
   ```
5. **Reset all privileged account passwords** — Administrator, all DA accounts
6. **Audit all accounts with DCSync rights** — only DCs should have replication rights:
   ```powershell
   # Check who has replication rights on domain root
   (Get-Acl "AD:").Access | Where-Object { $_.ActiveDirectoryRights -match "ExtendedRight" } | Select IdentityReference, ActiveDirectoryRights
   ```

---

## 🔒 Hardening Measures

| Control | Action |
|---------|--------|
| Least privilege | Remove DCSync rights from all non-DC accounts immediately |
| Tiered admin model | Service accounts (like `svc_asrep`) should never have domain-level privileges |
| Privileged Access Workstations | Admin tasks only from hardened PAWs |
| krbtgt rotation | Rotate krbtgt password every 180 days as standard practice |
| Alert on EID 4662 | Ensure SIEM rule fires on non-DC accounts triggering replication events |
| MDE/EDR coverage | Monitor for `lsass` access and `DRSUAPI` RPC calls from non-DC hosts |

---

## 🔁 Why DCSync Is So Dangerous

Unlike traditional credential dumping (e.g. `lsass` memory), DCSync:
- Requires **no code execution on the DC** — purely network-based
- Is **invisible to endpoint AV/EDR on the DC** — looks like legitimate replication
- Extracts **every account hash in the domain** including `krbtgt` (enabling Golden Ticket attacks)
- Can be performed by **any account with replication rights** — not just Domain Admins

---

## 📋 Post-Incident Checklist

- [ ] `svc_asrep` disabled
- [ ] DCSync rights revoked from `svc_asrep`
- [ ] `krbtgt` password reset twice
- [ ] All DA passwords reset
- [ ] Audit log reviewed for any lateral movement post-dump
- [ ] Detection rule confirmed active in SIEM
- [ ] Incident documented and closed
