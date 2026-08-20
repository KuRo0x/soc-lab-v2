# INC-003 — Detection Notes

## Key Event

**EID 4769** — A Kerberos service ticket was requested

The smoking gun is `TicketEncryptionType: 0x17` (RC4-HMAC). Modern Windows clients request AES (`0x12` / `0x11`). RC4 requests from non-legacy systems indicate Kerberoasting.

---

## KQL Query — Kibana

### Primary Detection (RC4 TGS request)
```kql
event.code: "4769"
AND winlog.event_data.TicketEncryptionType: "0x17"
AND winlog.event_data.TicketOptions: "0x40810000"
```

### Broaden — All 4769 events (find baseline first)
```kql
event.code: "4769"
AND winlog.event_data.ServiceName: *
```

### Filter noise — exclude machine accounts and krbtgt
```kql
event.code: "4769"
AND winlog.event_data.TicketEncryptionType: "0x17"
AND NOT winlog.event_data.ServiceName: "krbtgt"
AND NOT winlog.event_data.ServiceName: (*$ OR DOMAIN*)
```

---

## What to Look For in the Event

```
Event ID:          4769
Account Name:      svc_asrep          <- the attacker's credential used
Service Name:      svc_http           <- target SPN account
Client Address:    172.16.0.11        <- Kali IP
Ticket Encryption: 0x17               <- RC4 = Kerberoasting indicator
Ticket Options:    0x40810000         <- forwardable ticket
```

---

## Evidence Checklist

- [ ] Screenshot of 4769 event in Kibana
- [ ] `Client Address` showing Kali (`172.16.0.11`)
- [ ] `TicketEncryptionType: 0x17` confirmed
- [ ] `ServiceName: svc_http` confirmed
- [ ] Saved KQL search in Kibana
