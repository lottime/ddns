#!/bin/bash
# Dnspod: https://www.dnspod.cn/docs/index.html
# IP check: ip.3322.org, ifconfig.me, ipinfo.io/ip, ipecho.net/plain, myip.ipip.net
# Copyright (c) timelass.com

# ---------- CONFIG BEGIN ---------- #
apiId=
apiToken=
domain=timelass.com
subdomain=ddns
ipCheckUrl=ip.3322.org
# ----------- CONFIG END ----------- #

dnsUrl="https://dnsapi.cn"
dnsToken="login_token=${apiId},${apiToken}&format=json&domain=${domain}&sub_domain=${subdomain}"
ipReg="([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"

getLocalIp() {
  echo `curl -s $ipCheckUrl` | grep -Eo "$ipReg" | tail -n1
}

getCurrentDnsIp() {
  echo `ping -c1 $subdomain.$domain` | grep -Eo "$ipReg" | tail -n1
}

getDnsRecords() {
  echo `curl -s -X POST $dnsUrl/Record.List -d $dnsToken`
}

# $1: record list
# $2: record key
getDnsInfoByKey() {
  echo ${1#*\"records\"\:*\"$2\"} | cut -d'"' -f2
}

# $1: record id
# $2: record line id
# $3: record type
# $4: record value
updateDnsRecord() {
  echo `curl -s -X POST $dnsUrl/Record.Modify -d "$dnsToken&record_id=$1&record_line_id=$2&record_type=$3&value=$4"`
}

datetime=$(date +"%Y-%m-%d %H:%M:%S")
localIp=$(getLocalIp)

if [ "$localIp" == "$(getCurrentDnsIp)" ];then
  echo "[$datetime] DDNS UPDATE SKIPPED-1: $localIp"
else
  records=$(getDnsRecords)
  recordId=$(getDnsInfoByKey "$records" 'id')
  recordLineId=$(getDnsInfoByKey "$records" 'line_id')
  recordType=$(getDnsInfoByKey "$records" 'type')
  recordIp=$(getDnsInfoByKey "$records" 'value')

  if [ -n "$recordId" ] && [ -n "$recordLineId" ] && [ -n "$recordType" ] && [ -n "$recordIp" ]; then
    if [ "$localIp" == "$recordIp" ];then
      echo "[$datetime] DDNS UPDATE SKIPPED-2: $localIp"
    else
      result=$(updateDnsRecord "$recordId" "$recordLineId" "$recordType" "$localIp")
      code="$(echo ${result#*code\"}|cut -d'"' -f2)"
      message="$(echo ${result#*message\"}|cut -d'"' -f2)"

      if [ "$code" == "1" ]; then
        echo "[$datetime] DDNS UPDATE SUCCESSFUL: $recordIp -> $localIp"
      else
        echo "[$datetime] DDNS UPDATE FAIL: $message"
      fi
    fi
  fi
fi
