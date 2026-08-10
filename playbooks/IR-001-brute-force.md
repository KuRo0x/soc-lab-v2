# IR-001 — Brute Force / Password Spray

## Detection
- **Source:** Windows Security Log (Event ID 4625 — failed logon)
- **ELK Query:**
```
event.code:4625 AND winlog.event_data.LogonType:3
```
- **Threshold:** >10 failed logons from same source IP in 5 minutes

## Investigation Steps
1. Identify source IP from `winlog.event_data.IpAddress`
2. Check if IP is internal (lateral movement) or external
3. Check targeted accounts — service accounts? admin accounts?
4. Correlate with Event ID 4624 (successful logon) — did any succeed?
5. Check Responder logs on Kali if LLMNR poisoning suspected

## Containment
- Block source IP at pfSense
- Disable compromised account if logon succeeded
- Force password reset

## Evidence to Collect
- [ ] ELK query screenshot
- [ ] Source IP
- [ ] Targeted accounts list
- [ ] Timeline of events
