# Filebeat Config

- **Applied to:** Ubuntu Victim (172.16.0.20)
- **Output:** ⚠️ `output.elasticsearch` currently commented out — verify destination

Place your `filebeat.yml` in this directory.

## TODO
- [ ] Verify where logs are being sent (Logstash? Direct ES?)
- [ ] Run `sudo filebeat test output` to confirm
