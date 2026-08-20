# Winlogbeat Configs — soc-lab-v2

## Files

| File | Host | IP | Install Path | Status |
|------|------|----|--------------|--------|
| `dc-winlogbeat.yml` | DC | 172.16.0.5 | `C:\Program Files\Winlogbeat\winlogbeat.yml` | ✅ Running |
| `win10-winlogbeat.yml` | Win10 Victim | 172.16.0.10 | `C:\Program Files\Winlogbeat\winlogbeat.yml` | ✅ Running |

## Output

Both hosts ship to **Logstash** on `172.16.0.4:5044` (not directly to Elasticsearch).

## Key Differences — DC vs Win10

| Setting | DC | Win10 |
|---------|----|-------|
| Winlogbeat version | Unknown | **9.4.2** |
| Install path | `C:\Program Files\Winlogbeat\` ✅ | `C:\Program Files\Winlogbeat\` ✅ |
| Event logs | Identical | Identical |
| Output | Logstash 5044 | Logstash 5044 |

## ⚠️ Known Issues

- **Kibana host** is commented out on both — uncomment `172.16.0.4:5601` under `setup.kibana` and run `winlogbeat setup` to load dashboards/ILM
- **DC version** not yet confirmed — check with `winlogbeat version` on 172.16.0.5

## Useful Commands

```powershell
# Test config
winlogbeat.exe test config -c winlogbeat.yml

# Test connectivity to Logstash output
winlogbeat.exe test output -c winlogbeat.yml

# Check version
winlogbeat.exe version

# Restart service
Restart-Service winlogbeat
```
