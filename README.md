# ddns
A little shell for DDNS (dnspod.cn) update with only one script file.

### 1. 配置文件
下载 dnspod.sh 文件至服务器，打开并修改其中配置项：

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
设置文件可执行权限：
```
chmod +x /path/to/dnspod.sh
```

### 2. 定时任务
加入系统定时任务（此例为每小时执行一次）：
```
crontab -e
0 */1 * * * /path/to/dnspod.sh >> /path/to/dnspod.log
```

### 3. 其他说明
本程序运行时，会首先检测域名当前生效的IP，如果相同则退出；其次检测域名Dnspod记录中的IP，相同则退出；最后才真正执行更新操作，以减少记录的更新次数（dnspod对API调用次数有一定限制）。
