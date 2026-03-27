#!/usr/bin/env bash
set -euo pipefail
cd /home/$(whoami)
addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
echo "ADDR:$addr"
echo "POST /Startup/Configuration"
code1=$(curl -sS -w "%{http_code}" -o /tmp/jf_conf_resp.json -X POST "http://$addr:8096/Startup/Configuration" -H "Content-Type: application/json" -d '{"MetadataCountryCode":"DE","PreferredMetadataLanguage":"de","UICulture":"de-DE"}' || true)
echo "HTTP:$code1"
cat /tmp/jf_conf_resp.json; echo
echo "POST /Startup/User"
code2=$(curl -sS -w "%{http_code}" -o /tmp/jf_user_resp.json -X POST "http://$addr:8096/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"admin\",\"Password\":\"Password123!\"}" || true)
echo "HTTP:$code2"
cat /tmp/jf_user_resp.json; echo
echo "POST /Startup/RemoteAccess"
code3=$(curl -sS -w "%{http_code}" -o /tmp/jf_remote_resp.json -X POST "http://$addr:8096/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}' || true)
echo "HTTP:$code3"
cat /tmp/jf_remote_resp.json; echo
echo "POST /Startup/Complete"
code4=$(curl -sS -w "%{http_code}" -o /tmp/jf_complete_resp.json -X POST "http://$addr:8096/Startup/Complete" -H "Content-Type: application/json" -d '{}' || true)
echo "HTTP:$code4"
cat /tmp/jf_complete_resp.json; echo
