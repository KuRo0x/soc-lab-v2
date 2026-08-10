# Changelog

All notable changes to this lab are documented here.
Format: `[YYYY-MM-DD] — What changed and why`

---

## [2026-08-11] — Initial build
- Deployed pfSense, ELK, DC (soc.lab), Kali, Win10, Ubuntu Victim, FLARE-VM
- Sysmon deployed on DC: sysmon-modular v4.90 (Olaf Hartong), balanced/medium verbosity, MITRE ATT&CK technique tagging in rule names
- Winlogbeat deployed on DC, shipping to ELK
- Filebeat deployed on Ubuntu Victim (output destination TBC)
- FLARE-VM isolated from outbound traffic via pfSense block rule — no telemetry by design
- Repo initialized with full enterprise-grade documentation structure

## [TODO — Next Steps]
- Verify Win10 Victim Sysmon + Winlogbeat
- Confirm Filebeat output destination on Ubuntu
- Install BloodHound on Kali
- Confirm ELK indices receiving data
- Begin executing incident scenarios (INC-001 onward)
