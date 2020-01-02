#!/bin/bash
# Copyright (c) cloudseat.net
# Cloudflare API document: https://api.cloudflare.com/#dns-records-for-a-zone-properties
# WAN IP check: ip.3322.org, ifconfig.me, ipinfo.io/ip, ipecho.net/plain, myip.ipip.net

# ---------- CONFIG BEGIN ---------- #
auth_email=
auth_key=
domain=
hosts=*,@
# ----------- CONFIG END ----------- #

ipCheckUrl=ip.3322.org
dnsApi="https://api.cloudflare.com/client/v4/zones"

# Get local WAN IP
function getLocalIp() {
  local ipReg="([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"
  echo `curl -s $ipCheckUrl` | grep -Eo "$ipReg" | tail -n1
}

# $1: json data
# $2: json key
function getJsonValue() {
  echo $1 | python -c "import sys, json; print json.load(sys.stdin)$2"
}

# $1: domain
# $2: host name
function checkAndUpdate() {
  local host
  if [ "$2" == "@" ]; then
    host="$1"
  else
    host="$2.$1"
  fi

  local zone=$(curl -s -X GET "$dnsApi?name=$1" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json")
  local domainId=$(getJsonValue "$zone" "['result'][0]['id']")
  local record=$(curl -s -X GET "$dnsApi/$domainId/dns_records?name=$host" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json")
  local recordId=$(getJsonValue $record "['result'][0]['id']")
  local recordIp=$(getJsonValue $record "['result'][0]['content']")
  local recordType=$(getJsonValue $record "['result'][0]['type']")
  local datetime=$(date +"%Y-%m-%d %H:%M:%S")

  if [ "$localIp" == "$recordIp" ]; then
    echo "[$datetime] '$host' ddns update skipped: $localIp"
  else
    result=$(curl -s -X PUT "$dnsApi/$domainId/dns_records/$recordId" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"id\":\"$domainId\",\"type\":\"$recordType\",\"name\":\"$host\",\"content\":\"$localIp\"}")

    success=$(getJsonValue $result "['success']")
    if [ "$success" == "True" ]; then
      echo "[$datetime] '$host' ddns update successful: $recordIp -> $localIp"
    else
      error=$(getJsonValue $result "['errors']")
      echo "[$datetime] '$host' ddns update failed: $error"
    fi
  fi
}

# Update records loop
set -f
localIp=$(getLocalIp)
array=(${hosts//,/ })
for host in ${array[*]};do
  checkAndUpdate "$domain" "$host"
done
