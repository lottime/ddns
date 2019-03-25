# ddns
A little shell for DDNS (dnspod.cn) update.

本程序只有一个文件：dnspod.sh，下载该文件至服务器，打开修改其中的配置项：

```
# ---------- CONFIG BEGIN ---------- #
# dnspod.cn 注册的ID
apiId=
# dnspod.cn 注册的TOKEN
apiToken=
# dnspod.cn 事先设置要解析的域名（如example.com）
domain=
# dnspod.cn 事先设置要解析的主机记录（如www）
subdomain=
# 用于检测服务器动态IP的地址
ipCheckUrl=ip.3322.org
# ----------- CONFIG END ----------- #
```

加入系统定时任务（此例为每小时执行一次）：
```
crontab -e
0 */1 * * * /path/to/dnspod.sh >> /path/to/dnspod.log
```

程序运行时，会首先检测域名当前生效的IP，如果相同则退出；其次检测域名Dnspod记录中的IP，相同则退出；最后才真正执行更新操作，以减少记录的更新次数（dnspod对API调用次数有一定限制）。
