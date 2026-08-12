# Incident Response Process

> Applies to: soc-lab-v2 | Framework: NIST SP 800-61r2

This playbook defines the end-to-end IR workflow used for all scenarios in this lab. It mirrors real enterprise SOC procedures.

---

## Phase 1 — Preparation

Before any scenario runs:
- [ ] Confirm Winlogbeat and Filebeat are shipping to ELK
- [ ] Verify relevant audit policies are enabled (`auditpol`)
- [ ] Take VM snapshots of all relevant machines
- [ ] Confirm the correct Kibana index exists (`winlogbeat-*`, `filebeat-*`)
- [ ] Document baseline — what does normal look like?

---

## Phase 2 — Detection & Analysis (Triage)

```
1. Alert fires (Sigma rule / Kibana alert / manual hunt)
2. Identify the event: What event ID? What source host? What account?
3. Determine scope: Is this one host or multiple?
4. Pull timeline: What happened 10 minutes before and after?
5. Classify: True Positive / False Positive / Needs escalation
```

### Key Questions During Triage
- What account was involved? Is it a service account, privileged account, or user?
- What source IP? Is it a known asset or unknown?
- Is there lateral movement? Check 4624/4625 from the same source.
- Is there persistence? Check Sysmon Event ID 1 (process create) and 7045 (new service).

---

## Phase 3 — Containment

| Scenario | Immediate Containment |
|----------|-----------------------|
| AS-REP Roasting | Disable `svc_asrep`, reset password, re-enable PreAuth |
| Kerberoasting | Rotate service account password (25+ chars) |
| Pass-the-Hash | Isolate source host, invalidate NTLM tokens |
| DCSync | Disable compromised account, audit replication permissions |
| C2 Beacon | Block C2 IP/domain on pfSense, isolate host |

---

## Phase 4 — Eradication

- Remove the attack tool/persistence mechanism
- Rotate all credentials that may have been exposed
- Patch the vulnerability or misconfiguration that was exploited
- Verify no backdoors remain (Sysmon Event ID 1, 7, 11)

---

## Phase 5 — Recovery

- Restore from snapshot if system integrity is in question
- Re-enable affected accounts only after password rotation
- Confirm telemetry is restored and baselines look normal
- Document timeline of events for the scenario writeup

---

## Phase 6 — Lessons Learned

After every scenario:
- [ ] Sigma rule created or updated?
- [ ] Hardening control documented in `playbooks/lab-hardening.md`?
- [ ] `STATUS.md` updated?
- [ ] `detection/coverage-matrix.md` updated?
- [ ] IOCs documented in `threat-scenarios/INC-XXX/iocs.md`?
