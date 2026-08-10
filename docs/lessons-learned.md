# 📓 Lessons Learned / Engineering Log

> Updated after every incident or significant lab change.

---

## [2026-08-11] — Initial Build

**Observation:** FLARE-VM (172.16.0.30) reaches ELK and DC directly over LAN even with pfSense outbound block rule. Intra-subnet traffic doesn't traverse the firewall — only routed traffic does.

**Decision:** Accepted for now. FLARE-VM isolation goal is internet access prevention and outbound exfiltration blocking, not full LAN isolation. If stronger isolation needed → separate VLAN with ACLs.

**Observation:** Ubuntu Victim Filebeat has `output.elasticsearch` commented out. Logs appear running but destination is unclear.

**Action:** TODO — run `sudo filebeat test output` on 172.16.0.20 to confirm.

**Observation:** BloodHound not installed on Kali despite being a core AD enumeration tool.

**Action:** `sudo apt install bloodhound -y` — pending.

---

## Template

```
## [YYYY-MM-DD] — Topic

**Observation:** What you noticed.
**Root cause:** Why it happened.
**Decision/Fix:** What you did.
**Lesson:** What you'd do differently.
```
