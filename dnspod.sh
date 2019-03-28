#!/bin/bash
# Copyright (c) timelass.com
# Dnspod API document: https://www.dnspod.cn/docs/index.html
# WAN IP check: ip.3322.org, ifconfig.me, ipinfo.io/ip, ipecho.net/plain, myip.ipip.net

# ---------- CONFIG BEGIN ---------- #
apiId=
apiToken=
domain=
hosts=
ipCheckUrl=ip.3322.org
# ----------- CONFIG END ----------- #

dnsUrl="https://dnsapi.cn"
dnsToken="login_token=${apiId},${apiToken}&format=json"
ipReg="([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"

# Get local WAN IP
getLocalIp() {
  echo `curl -s $ipCheckUrl` | grep -Eo "$ipReg" | tail -n1
}

# $1: domain
# $2: host name
getCurrentDnsIp() {
  echo `ping -c1 $2.$1` | grep -Eo "$ipReg" | tail -n1
}

# $1: domain
# $2: host name
getDnsRecords() {
  echo `curl -s -X POST $dnsUrl/Record.List -d "$dnsToken&domain=$1&sub_domain=$2"`
}

# $1: record list
# $2: record key
getDnsInfoByKey() {
  echo ${1#*\"records\"\:*\"$2\"} | cut -d'"' -f2
}

# $1: domain
# $2: host name
# $3: record id
# $4: record line id
# $5: record type
# $6: record value
updateDnsRecord() {
  echo `curl -s -X POST $dnsUrl/Record.Modify -d "$dnsToken&domain=$1&sub_domain=$2&record_id=$3&record_line_id=$4&record_type=$5&value=$6"`
}

# $1: domain
# $2: host name
checkAndUpdate() {
  datetime=$(date +"%Y-%m-%d %H:%M:%S")
  localIp=$(getLocalIp)

  host=$2
  if [ "$host" == "*" ];then host="any"; fi
 
  if [ "$localIp" == "$(getCurrentDnsIp $1 $host)" ];then
    echo "[$datetime] '$2.$1' ddns update skipped-1: $localIp"
  else
    records=$(getDnsRecords "$1" "$2")
    recordId=$(getDnsInfoByKey "$records" "id")
    recordLineId=$(getDnsInfoByKey "$records" "line_id")
    recordType=$(getDnsInfoByKey "$records" "type")
    recordIp=$(getDnsInfoByKey "$records" "value")

    if [ -n "$recordId" ] && [ -n "$recordLineId" ] && [ -n "$recordType" ] && [ -n "$recordIp" ]; then
      if [ "$localIp" == "$recordIp" ];then
        echo "[$datetime] '$2.$1' ddns update skipped-2: $localIp"
      else
        result=$(updateDnsRecord "$1" "$2" "$recordId" "$recordLineId" "$recordType" "$localIp")
        code="$(echo ${result#*code\"}|cut -d'"' -f2)"
        message="$(echo ${result#*message\"}|cut -d'"' -f2)"

        if [ "$code" == "1" ]; then
          echo "[$datetime] '$2.$1' ddns update successful: $recordIp -> $localIp"
        else
          echo "[$datetime] '$2.$1' ddns update failed: $message"
        fi
      fi
    fi
  fi
}

# Update records loop
set -f
array=(${hosts//,/ })
for host in ${array[*]};do
  checkAndUpdate "$domain" "$host"
done
