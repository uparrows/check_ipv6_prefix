两个脚本用途不同！

# check_ipv6_prefix脚本
用于检查基于openwrt（lede（lean的18.06分支））的ipv6分发前缀是否存在，使用ifstatus命令查看发现lede（lean的18.06分支）的ipv6前缀位于lan口，如果没有检测到分发前缀就重启wan口重新拨号，解决某些运营商网络pppoe拨号一段时间后ipv6分发前缀丢失造成群晖等ddns失效。

详见：https://yuanfangblog.xyz/technology/851.html



将脚本下载后放入/usr/bin目录下，chmod +x 修改权限后添加openwrt计划任务每10分钟检测一次：

*/10 * * * * /usr/bin/check_ipv6_prefix.sh


# copy_ipv6_prefix脚本
用于新版lede虽然wan口能获取ipv6，但是查看IPv6 WAN 状态无分发前缀，造成无法下发ipv6，常见状态为 系统日志报错： A default route is present but there is no public prefix on lan thus we don't announce a default route!，路由器自身获取到ipv6，路由器下其他设备无法获取ipv6，该脚本原理是强行复制wan口的分发前缀（使用命令ifstatus lan可以看到ipv6-prefix-assignmen），使得能够下发ipv6地址到内网各设备，测试lede版本R25.10.10.

将脚本下载后放入/usr/bin目录下，chmod +x 修改权限后添加openwrt计划任务每10分钟检测一次：

*/10 * * * * /usr/bin/copy_ipv6_prefix.sh
