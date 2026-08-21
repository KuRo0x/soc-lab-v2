# INC-XXX — Remediation

> Fill this in immediately after the incident write-up is complete.

---

## Impact Statement

> What would a real organisation have suffered if this were a live breach?

- **Confidentiality:** [e.g., credentials exposed, accounts compromised]
- **Integrity:** [e.g., potential for privilege escalation, lateral movement]
- **Availability:** [e.g., no immediate impact / ransomware risk if credentials reused]
- **Business impact:** [e.g., domain compromise, data exfiltration, regulatory exposure]

---

## Immediate Remediation Actions

- [ ] Reset all affected account passwords
- [ ] Disable/remove attack vector (e.g., disable the misconfigured account)
- [ ] Revoke/expire any issued tickets (reboot affected hosts or `klist purge`)
- [ ] Block attacker IP at perimeter

---

## Control / Protocol Changes

| Control | Action | Owner | Status |
|---------|--------|-------|--------|
| [e.g., Enforce pre-auth] | [GPO / AD change] | [SysAdmin] | TODO |

---

## Detection Improvements

- Sigma rule deployed: [link to `.yml`]
- Kibana alert created: [yes / TODO]
- Coverage matrix updated: [yes / TODO]

---

## Awareness Artefact

> A short memo aimed at IT staff, service-account owners, or end users explaining what happened and what has changed. Write in plain language.

**To:** IT Staff / Service Account Owners  
**Re:** [Technique] — Security Improvement Implemented  
**Date:** YYYY-MM-DD  

We recently identified and remediated a misconfiguration that could allow an attacker to extract and crack account credentials without any password prompt. [One-sentence plain explanation of the technique.]  

As a result, we have [control change]. Going forward, [what staff should know or do differently].  

If you manage a service account or have any questions, please contact [team/person].
