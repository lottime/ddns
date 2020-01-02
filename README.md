# DDNS.sh 使用说明
动态更新域名解析记录的脚本，支持 dnspod 和 cloudflare。

## 一. 下载脚本

```bash
git clone https://github.com/someworks/ddns.sh.git
```

## 二. 修改配置

根据不同的域名服务商打开对应的脚本文件，例如`dnspod.sh`或`cloudflare.sh`，修改其中头部的配置项，以`dnspod.sh`为例：

```bash
# ---------- CONFIG BEGIN ---------- #
# dnspod.cn 注册的ID
apiId=
# dnspod.cn 注册的TOKEN
apiToken=
# dnspod.cn 事先设置要解析的域名，如 example.com
domain=
# dnspod.cn 事先设置要解析的主机记录，多个记录以逗号分隔，如 www,@,*,api,blog
hosts=
# ----------- CONFIG END ----------- #
```

保存后设置文件可执行权限：

```bash
chmod +x dnspod.sh
```

## 三. 定时任务

加入系统定时任务（此例为每小时执行一次）：

```bash
crontab -e
0 */1 * * * /path/to/dnspod.sh >> /path/to/dnspod.log
```

## 四. 其他说明

由于 Dnspod 对 API 调用频率有一定限制，所以本程序运行时，会首先检测域名当前生效的IP，如果相同则退出；其次检测域名 Dnspod 记录中的IP，相同则退出；最后才真正执行更新操作，以减少记录的更新次数。
