# check_ipv6_prefix
检查基于openwrt（lede（lean的18.06分支））的ipv6分发前缀是否存在，使用ifstatus命令查看发现lede（lean的18.06分支）的ipv6前缀位于lan口，如果没有检测到分发前缀就重启wan口重新拨号，解决某些运营商网络pppoe拨号一段时间后ipv6分发前缀丢失造成群晖等ddns失效。

详见：https://yuanfangblog.xyz/technology/851.html



将脚本下载后放入/usr/bin目录下，chmod +x 修改权限后添加openwrt计划任务每10分钟检测一次：

*/10 * * * * /usr/bin/check_ipv6_prefix.sh
