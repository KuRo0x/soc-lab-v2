# 📦 ELK Stack — SIEM

## Host
- **IP:** 172.16.0.4
- **OS:** Ubuntu 22.04
- **Stack:** Elasticsearch + Kibana + Logstash

## Access
| Service | URL | Port |
|---------|-----|------|
| Kibana | https://172.16.0.4:5601 | 5601 |
| Elasticsearch | https://172.16.0.4:9200 | 9200 |
| Logstash Beats input | 172.16.0.4:5044 | 5044 |

## Status
- [x] Elasticsearch running
- [x] Kibana running
- [x] TLS enabled
- [ ] Index verification (winlogbeat-*, filebeat-*) — TODO
- [ ] Kibana dashboards configured — TODO
- [ ] Detection/alerting rules — TODO

## Indices (Expected)
| Index Pattern | Source | Status |
|---------------|--------|--------|
| `winlogbeat-*` | DC (172.16.0.5) + Win10 (172.16.0.10) | DC verified |
| `filebeat-*` | Ubuntu Victim (172.16.0.20) | Running, output TBC |

## Quick Health Check
```bash
curl -k -u elastic:PASS https://172.16.0.4:9200/_cluster/health?pretty
curl -k -u elastic:PASS https://172.16.0.4:9200/_cat/indices?v
```
