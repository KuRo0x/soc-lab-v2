# INC-003 — Kerberoasting

> **Status:** 🔲 Pending
> **MITRE ATT&CK:** [T1558.003 - Steal or Forge Kerberos Tickets: Kerberoasting](https://attack.mitre.org/techniques/T1558/003/)
> **Tactic:** Credential Access
> **Tool:** Impacket `GetUserSPNs.py` + Hashcat
> **Difficulty:** Low — requires one valid domain user account

---

## Overview

Kerberoasting targets service accounts that have a Service Principal Name (SPN) registered in AD. Any authenticated domain user can request a TGS (service ticket) for any SPN — the ticket is encrypted with the service account's password hash. The attacker takes this offline and cracks it with hashcat (mode 13100).

**Key difference from AS-REP Roasting:** Kerberoasting requires at least one valid domain credential first. AS-REP requires none.

---

## Status

🔲 **Not yet executed.** Next in queue after INC-002.
