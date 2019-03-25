# ddns
一个针对 Dnspod 动态域名解析记录更新的小壳子，本程序只有一个文件。

### 1. 配置文件
下载 dnspod.sh 文件至服务器，修改其中配置项：

```
# ---------- CONFIG BEGIN ---------- #
# dnspod.cn 注册的ID
apiId=
# dnspod.cn 注册的TOKEN
apiToken=
# dnspod.cn 事先设置要解析的域名，如 example.com
domain=
# dnspod.cn 事先设置要解析的主机记录，多个记录以逗号分隔，如 www,@,api,blog
hosts=
# 用于检测服务器动态公网IP的地址
ipCheckUrl=ip.3322.org
# ----------- CONFIG END ----------- #
```
保存后设置文件可执行权限：
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
由于 Dnspod 对 API 调用频率有一定限制，所以本程序运行时，会首先检测域名当前生效的IP，如果相同则退出；其次检测域名 Dnspod 记录中的IP，相同则退出；最后才真正执行更新操作，以减少记录的更新次数。
