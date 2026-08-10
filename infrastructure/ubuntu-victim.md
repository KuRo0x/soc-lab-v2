# 🐧 Ubuntu 22.04 — Victim VM

## Host
- **IP:** 172.16.0.20
- **Hostname:** soc-lab-victim
- **User:** walid-v
- **OS:** Ubuntu 22.04

## Status
- [x] Network OK — reaches pfSense and DC
- [x] Filebeat — installed and running (active since 2026-08-10 23:11 UTC)
- [ ] Filebeat output — `output.elasticsearch` is commented out in config ⚠️
- [ ] Docker installed (docker0 interface present) — purpose TBD

## ⚠️ Filebeat Output Issue
The current `filebeat.yml` has `#output.elasticsearch:` commented out.
Need to confirm where logs are being sent (Logstash on port 5044?).

```bash
# Check full filebeat config output section
sudo cat /etc/filebeat/filebeat.yml | grep -A 10 "output"

# Check filebeat logs
sudo journalctl -u filebeat -n 50

# Check if filebeat is connecting to ELK
sudo filebeat test output
```

## TODO
- [ ] Verify Filebeat output destination
- [ ] Confirm `filebeat-*` index receiving data in ELK
- [ ] Document Docker usage (is it intentional? which containers?)
