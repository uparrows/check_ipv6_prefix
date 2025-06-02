#!/bin/sh

# 获取IPv6前缀的函数
get_ipv6_prefix() {
    ifstatus lan | jsonfilter -e '@["ipv6-prefix-assignment"][0]["address"]' -e '@["ipv6-prefix-assignment"][0]["mask"]' | awk 'NR==1{prefix=$0} NR==2{mask=$0; print prefix "/" mask}'
}

# 检测IPv6前缀
ipv6_prefix=$(get_ipv6_prefix)

if [ -z "$ipv6_prefix" ]; then
    logger -t IPv6_PREFIX_CHECK "未检测到IPv6分发前缀，尝试重启WAN接口..."
    echo "$(date) - 未检测到IPv6分发前缀，尝试重启WAN接口..." >> /tmp/ipv6_check.log
    
    # 重启WAN接口
    ifdown wan && ifup wan
    
    # 等待300秒后再次检查(不需要了，直接添加计划任务 */10 * * * * /usr/bin/check_ipv6_prefix.sh ，10分钟运行一次脚本）
    #sleep 300
    #ipv6_prefix=$(get_ipv6_prefix)
    
    #if [ -z "$ipv6_prefix" ]; then
    #    logger -t IPv6_PREFIX_CHECK "重启WAN接口后仍未获取到IPv6前缀"
    #    echo "$(date) - 重启WAN接口后仍未获取到IPv6前缀" >> /tmp/ipv6_check.log
    #    exit 1
    #else
    #    logger -t IPv6_PREFIX_CHECK "重启WAN接口后成功获取IPv6前缀: $ipv6_prefix"
    #    echo "$(date) - 重启WAN接口后成功获取IPv6前缀: $ipv6_prefix" >> /tmp/ipv6_check.log
    #    exit 0
    #fi
else
    logger -t IPv6_PREFIX_CHECK "当前IPv6前缀正常: $ipv6_prefix"
    echo "$(date) - 当前IPv6前缀正常: $ipv6_prefix" >> /tmp/ipv6_check.log
    exit 0
fi