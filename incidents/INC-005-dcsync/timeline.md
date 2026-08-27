# INC-005 — Attack Timeline

> **Date:** 2026-08-27  
> **Attacker:** Kali (172.16.0.11)  
> **Target:** SOC-Lab-DC (172.16.0.5)

---

## Timeline

| Time (GMT+1) | Action | Detail |
|--------------|--------|--------|
| TBD | DCSync rights granted | `svc_asrep` delegated `Replicating Directory Changes` + `Replicating Directory Changes All` via ADUC on DC |
| TBD | Attack launched | `impacket-secretsdump soc.lab/svc_asrep:'Summer2024!'@172.16.0.5` executed from Kali |
| TBD | Credential dump complete | All domain hashes extracted including `Administrator`, `krbtgt`, and all user accounts |
| TBD | EID 4662 generated | DC Security log records replication access by `svc_asrep` |
| TBD | Detected in Kibana | KQL query returns EID 4662 with DCSync GUIDs in `winlogbeat-*` |
| TBD | Sigma rule validated | Rule fires on event, alert confirmed |

> ⚠️ Fill in timestamps as you execute each step in the lab.

---

## Attacker Path (MITRE ATT&CK)

```
Initial Access (assumed compromised svc_asrep)
    └── Privilege Escalation: DCSync rights granted
            └── Credential Access: T1003.006 — DCSync
                    └── impacket-secretsdump → all NTLM hashes extracted
                            └── Lateral Movement possible via PTH on any account
```
