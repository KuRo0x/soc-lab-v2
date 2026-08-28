# Suricata on pfSense — Configuration & ELK Integration

> **Deployed:** 2026-08-23 — 2026-08-26  
> **Status:** ✅ Operational — EVE JSON flowing into `suricata-eve-*` Elasticsearch index  
> **Related Issue:** #1 (closed 2026-08-28)

---

## 📋 Overview

Suricata 7.0.9 is deployed on pfSense 2.8.1 as an **IDS-only** sensor on the LAN interface (`em1`). EVE JSON logs are forwarded via syslog to Logstash on the ELK VM and indexed into Elasticsearch under the `suricata-eve-*` index pattern.

| Component | Value |
|---|---|
| Suricata version | 7.0.9 |
| pfSense version | 2.8.1 |
| Interface monitored | LAN (`em1`) |
| Mode | IDS-only (Block Offenders: disabled) |
| Run Mode | AutoFP |
| Pattern Match | AUTO |
| EVE Output Type | SYSLOG |
| Syslog destination | `172.16.0.4:5140` (Logstash) |
| Elasticsearch index | `suricata-eve-YYYY.MM.dd` |
| Logstash pipeline | `03-suricata-eve.conf` (port `5045`) |

---

## 🔧 Installation

1. Navigate to **System → Package Manager → Available Packages**
2. Search for `suricata` and install
3. Confirm version **7.0.9** under **Services → Suricata**

---

## ⚙️ Hardware Offloading (Required Fix)

Before configuring Suricata, disable hardware offloading to prevent packet inspection issues:

1. Go to **System → Advanced → Networking**
2. Disable all three options:
   - ☑ Disable hardware checksum offload
   - ☑ Disable hardware TCP segmentation offload
   - ☑ Disable hardware large receive offload
3. **Reboot pfSense**

---

## 🌐 LAN Interface Configuration

**Services → Suricata → Interfaces → Add**

| Setting | Value |
|---|---|
| Interface | LAN (em1) |
| EVE JSON Log | Enabled |
| EVE Output Type | **SYSLOG** |
| Block Offenders | Disabled |
| Run Mode | AutoFP |

### EVE Logged Traffic Types

| Type | Enabled |
|---|---|
| DNS | ✅ |
| HTTP | ✅ |
| Kerberos | ✅ |
| SMB | ✅ |
| TLS | ✅ |
| SSH | ✅ |

### Extended TLS Fields

| Field | Enabled |
|---|---|
| SNI | ✅ |
| JA3 | ✅ |
| JA3S | ✅ |
| Version | ✅ |
| Subject | ✅ |
| Issuer | ✅ |

---

## 📦 Rulesets

**Services → Suricata → Global Settings → Update**

| Ruleset | MD5 | Updated |
|---|---|---|
| ETOpen Emerging Threats | `ec3478e919b924fa8fc2bba9f522211c` | 2026-08-23 |
| Snort GPLv2 Community Rules | `3f4d1eb844dd5d55dc1079aa7143d6eb` | 2026-08-23 |
| Feodo Tracker Botnet C2 IP Rules | `ce4793f2307aa4c0fdcf1ddfad224820` | 2026-08-23 |
| ABUSE.ch SSL Blacklist Rules | `984753f29499463bdaf25d2265a72be2` | 2026-08-23 |

**Update Interval:** 12 Hours | **Start:** 00:12 | **Live Rule Swap:** Enabled

---

## 📡 Syslog Forwarding (pfSense → Logstash)

**Status → System Logs → Settings → Remote Logging**

| Setting | Value |
|---|---|
| Remote log server | `172.16.0.4:5140` |
| Remote Syslog Contents | Everything ✅ |

> **Note:** The pfSense syslog daemon (FreeBSD `syslogd`) truncates messages to **~480 bytes**. Full EVE JSON events (especially DNS with multiple answers) may arrive as broken JSON and cause Logstash parse failures. Monitor the `suricata-eve-*` index for `_jsonparsefailure` tags.

---

## 🔁 Logstash Pipeline — `03-suricata-eve.conf`

> Port: `5045` | Input: syslog | Output: `suricata-eve-*`

```ruby
input {
  syslog {
    port => 5045
    type => "suricata"
  }
}

filter {
  if [type] == "suricata" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP} %{SYSLOGHOST} %{DATA}(?:\[%{POSINT}\])?: %{GREEDYDATA:syslog_msg}" }
      tag_on_failure => ["_grok_failure"]
    }
    if [syslog_msg] =~ /\{.*\"event_type\"/ {
      json {
        source => "syslog_msg"
        target => "suricata"
      }
      mutate {
        add_tag => ["suricata_eve"]
        replace => { "type" => "suricata" }
      }
    }
  }
}

output {
  if "suricata_eve" in [tags] {
    elasticsearch {
      hosts => ["https://localhost:9200"]
      index => "suricata-eve-%{+YYYY.MM.dd}"
      user => "elastic"
      password => "<REDACTED>"
      ssl_enabled => true
      ssl_verification_mode => none
    }
  }
}
```

---

## ✅ Verification

### Confirmed Working (2026-08-26)

- `suricata-eve-2026.08.23` index present in Elasticsearch ✅
- EVE JSON events visible in Kibana under `suricata-eve-*` ✅
- Suricata green status on LAN interface ✅

### Kibana Index Pattern

| Setting | Value |
|---|---|
| Index pattern | `suricata-eve-*` |
| Time field | `@timestamp` |
| Key fields | `suricata.event_type`, `suricata.src_ip`, `suricata.dest_ip`, `suricata.alert.signature` |

---

## ⚠️ Known Limitations

| Issue | Detail | Mitigation |
|---|---|---|
| FreeBSD syslog truncation | Max ~480 bytes — long EVE events arrive as broken JSON | Monitor for `_jsonparsefailure`; consider `syslog-ng` or dedicated log forwarder VM |
| Filebeat on pfSense | No official Elastic FreeBSD binary available | Use syslog forwarding (current) or NFS/SSH + Filebeat on a proxy VM |
| IDS-only mode | Block Offenders disabled — alerts only, no blocking | Acceptable for lab; enable blocking for IPS mode if needed |

---

## 📌 Reference

| Item | Value |
|---|---|
| pfSense IP | `172.16.0.1` |
| ELK IP | `172.16.0.4` |
| Logstash syslog port (pfSense system) | `5140` |
| Logstash syslog port (Suricata EVE) | `5045` |
| EVE JSON log path (local) | `/var/log/suricata/suricata_em1*/eve.json` |
| MITRE technique (C2 detection) | T1071.001 — Application Layer Protocol: Web Protocols |
