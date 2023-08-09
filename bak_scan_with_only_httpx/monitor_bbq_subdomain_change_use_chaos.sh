#!/bin/bash

# 该文件建议使用 nohup ./monitor_bbq_subdomain_change_use_chaos.sh >nohup.out 2>&1 &命令在后台运行
# 定时循环使用chaos读取wildcarddomains.txtx文件，搜集所有域名的子域名变动情况

export CHAOS_KEY=xxxxxxxxxxxxxxxx

# 定义一些重复使用的变量
wildcard_file="wildcarddomains.txtx"
new_subdomains_file="new_downloadsubdomains_by_chaos.txtx"
all_domains_file="alldomains.txtx"
new_domains_file="new_domains.txtx"
changelog_all_file="changelog_alldomains.txtx"
changelog_chaos_file="changelog_chos.txtx"

# 定义一些重复使用的函数
function write_log() {
    local file=$1
    local message=$2
    echo "$message-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>$file
    echo -e >>$file
}

function notify() {
    local message=$1
    echo "$message-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
}

while true; do
    # 循环每5分钟根据wildcarddomains.txtx文件获取一次所有的子域名
    if [ -s $wildcard_file ]; then
        chaos -dL $wildcard_file -bbq -silent >>$new_subdomains_file
        if [ -s $new_subdomains_file ]; then
            if test ! -s $all_domains_file; then
                cat $new_subdomains_file >>$all_domains_file
                write_log $changelog_all