#!/bin/sh

# 获取WAN口IPv6分发前缀
get_wan_prefix() {
    ip -6 route show | grep default | sed -e 's/^.*from //g' | sed 's/ via.*$//g'
}

# 获取LAN口IPv6分发前缀
get_lan_prefix() {
    ifstatus lan 2>/dev/null | jsonfilter -e '@["ipv6-prefix-assignment"][0]["address"]' -e '@["ipv6-prefix-assignment"][0]["mask"]' | awk 'NR==1{prefix=$0} NR==2{mask=$0; print prefix "/" mask}'
}

# 主函数
main() {
    echo "正在检查IPv6前缀..."
    
    # 获取WAN口前缀
    wan_prefix=$(get_wan_prefix)
    echo "WAN口IPv6前缀: $wan_prefix"
    
    # 获取LAN口前缀
    lan_prefix=$(get_lan_prefix)
    echo "LAN口IPv6前缀: $lan_prefix"
    
    # 检查WAN口前缀是否为空
    if [ -z "$wan_prefix" ]; then
        echo "错误: WAN口IPv6前缀为空，执行ifup wan..."
        ifup wan
        exit 1
    fi
    
    # 检查LAN口前缀是否为空
    if [ -z "$lan_prefix" ]; then
        echo "警告: LAN口IPv6前缀为空，需要更新配置..."
        update_network_config
        return
    fi
    
    # 比较WAN口和LAN口前缀是否一致
    if [ "$wan_prefix" != "$lan_prefix" ]; then
        echo "WAN口和LAN口IPv6前缀不一致，需要更新配置..."
        update_network_config
    else
        echo "WAN口和LAN口IPv6前缀一致，无需操作。"
    fi
}

# 更新网络配置函数
update_network_config() {
    echo "正在更新网络配置..."
    
    # 获取当前的WAN口前缀
    current_wan_prefix=$(get_wan_prefix)
    
    if [ -n "$current_wan_prefix" ]; then
        echo "设置ULA前缀为: $current_wan_prefix"
        uci set network.globals.ula_prefix="$current_wan_prefix"
        uci commit network
        echo "重启LAN接口..."
        ifup lan
        echo "网络配置更新完成。"
    else
        echo "错误: 无法获取有效的WAN口IPv6前缀，跳过更新。"
    fi
}

# 运行主函数
main
