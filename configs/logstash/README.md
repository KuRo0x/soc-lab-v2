# Logstash Pipeline Configs

Two pipelines are active on the ELK VM (`172.16.0.4`).

## Files

| File | Pipeline | Port | Index |
|------|----------|------|-------|
| `pfsense-input.conf` | pfSense syslog ingestion | `5140` (UDP/TCP) | `pfsense-firewall-YYYY.MM.dd` |
| `beats-input.conf` | Winlogbeat + Filebeat ingestion | `5044` (TCP) | `%{beat}-YYYY.MM.dd` |

## Credentials

The `${ELASTIC_PASSWORD}` placeholder in both configs maps to the `elastic` superuser password.  
The real value is stored in the password manager — **never commit it here**.

## Location on ELK VM

```
/etc/logstash/conf.d/
├── pfsense-input.conf
└── beats-input.conf
```

## Restart Logstash

```bash
sudo systemctl restart logstash
sudo systemctl status logstash
```
