# check_ipv6_prefix
检查基于openwrt（lede（lean的18.06分支））的ipv6分发前缀是否存在，如果没有就重启wan口重新拨号，解决某些运营商网络pppoe拨号一段时间后ipv6分发前缀丢失造成群晖等ddns失效
详见：https://yuanfangblog.xyz/technology/851.html
