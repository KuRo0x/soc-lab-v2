# Detection Engineering

This directory contains all detection content for soc-lab-v2.

> **Policy:** Nothing goes in here until it has been **tested against a real lab event**. No theoretical rules. No copy-paste from the internet without live validation.

## Structure

```
detection/
├── sigma/                    — Sigma rules, one per TTP, named by ATT&CK ID
├── kibana/                   — Exported Kibana saved searches and alerts
└── coverage-matrix.md        — What is and isn't covered — honest, live-only
```

## Sigma Rules (Live & Verified)

| File | Technique | Tested Against Real Event |
|------|-----------|---------------------------|
| [`T1003.006-dcsync.yml`](./sigma/T1003.006-dcsync.yml) | DCSync | ✅ Yes — Event 4662 confirmed |
| [`T1550.002-pass-the-hash.yml`](./sigma/T1550.002-pass-the-hash.yml) | Pass-the-Hash | ✅ Yes — Event 4624 confirmed |
| [`T1557.001-llmnr-ntlm-relay.yml`](./sigma/T1557.001-llmnr-ntlm-relay.yml) | LLMNR/NTLM Relay | ✅ Yes — Event 4662 confirmed |
| [`T1558.003-kerberoasting.yml`](./sigma/T1558.003-kerberoasting.yml) | Kerberoasting | ✅ Yes — Event 4769, `0x17` confirmed |
| [`T1558.004-asrep-roasting.yml`](./sigma/T1558.004-asrep-roasting.yml) | AS-REP Roasting | ✅ Yes — Event 4768, `0x17`, `PreAuthType: 0` confirmed |

## Naming Convention

```
T[technique-id]-[short-name].yml
Example: T1558.004-asrep-roasting.yml
```

## Validate a Rule

```bash
pip install sigma-cli
sigma convert -t lucene -p ecs_windows detection/sigma/T1558.004-asrep-roasting.yml
```
