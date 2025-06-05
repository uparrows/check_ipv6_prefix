#!/bin/sh

# 获取IPv6前缀的函数
get_ipv6_prefix() {
    ifstatus lan | jsonfilter -e '@["ipv6-prefix-assignment"][0]["address"]' -e '@["ipv6-prefix-assignment"][0]["mask"]' | awk 'NR==1{prefix=$0} NR==2{mask=$0; print prefix "/" mask}'
}

# 检测IPv6前缀
ipv6_prefix=$(get_ipv6_prefix)
log_msg=""
restart_wan=0

if [ -z "$ipv6_prefix" ]; then
    # 情况1：未检测到任何前缀
    log_msg="未检测到IPv6分发前缀，尝试重启WAN接口..."
    restart_wan=1
else
    # 提取前缀中的地址部分（去掉掩码）
    addr_part=${ipv6_prefix%%/*}
    
    # 检查是否是ULA地址（fc00::/7 范围）
    case ${addr_part:0:2} in
        fc|FC|fd|FD)
            # 情况2：检测到ULA前缀
            log_msg="检测到无效的ULA IPv6前缀: $ipv6_prefix，尝试重启WAN接口..."
            restart_wan=1
            ;;
        *)
            # 情况3：检测到公网前缀
            log_msg="当前IPv6前缀正常（公网）: $ipv6_prefix"
            ;;
    esac
fi

# 记录日志并执行操作
logger -t IPv6_PREFIX_CHECK "$log_msg"
echo "$(date) - $log_msg" >> /tmp/ipv6_check.log

if [ $restart_wan -eq 1 ]; then
    # 重启WAN接口
    ifdown wan && ifup wan
else
    exit 0
fi
