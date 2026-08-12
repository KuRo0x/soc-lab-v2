#!/bin/bash
# test-elk-pipeline.sh
# Validates that the ELK pipeline is healthy — indices exist, agents are shipping.
# Run from Kali or any host with curl access to ELK.

ELK_HOST="172.16.0.4"
ELK_PORT="9200"
ELK_USER="elastic"
ELK_PASS="<ELK_PASSWORD>"  # Replace with actual password — do not commit real value

echo ""
echo "[*] soc-lab-v2 — ELK Pipeline Validation"
echo "=========================================="

# Check cluster health
echo -e "\n[*] Cluster health:"
curl -sk -u "$ELK_USER:$ELK_PASS" "https://$ELK_HOST:$ELK_PORT/_cluster/health?pretty" | grep '"status"'

# Check winlogbeat index exists
echo -e "\n[*] Winlogbeat indices:"
curl -sk -u "$ELK_USER:$ELK_PASS" "https://$ELK_HOST:$ELK_PORT/_cat/indices/winlogbeat-*?v&h=index,docs.count,store.size"

# Check filebeat index exists
echo -e "\n[*] Filebeat indices:"
curl -sk -u "$ELK_USER:$ELK_PASS" "https://$ELK_HOST:$ELK_PORT/_cat/indices/filebeat-*?v&h=index,docs.count,store.size"

# Check most recent winlogbeat event
echo -e "\n[*] Most recent winlogbeat event:"
curl -sk -u "$ELK_USER:$ELK_PASS" \
  -H 'Content-Type: application/json' \
  "https://$ELK_HOST:$ELK_PORT/winlogbeat-*/_search?pretty" \
  -d '{"size":1,"sort":[{"@timestamp":{"order":"desc"}}],"_source":["@timestamp","agent.name","event.code","host.hostname"]}' \
  | grep -E '"@timestamp"|"agent.name"|"event.code"|"host.hostname"'

echo -e "\n[+] Done."
echo ""
