#!/bin/bash

# 将不含有赏金的根域名从根域名列表中筛选掉
# 总的 wildcarddomains.txtx，黑名单根域名文件为no_bbq_wildcarddomains.txtx
# 使用chaos每次单独请求根域名，如果返回[ERR] Could not get subdomains: invalid status code received: 404 - {"error":"Domain not in bbq scope"}则加入黑名单

if [ -s wildcarddomains.txtx ]; then
    while read -r domain; do
        command_results=$(chaos -key xxxxx -bbq -silent -d "$domain" -count 2>/dev/null)
        if ! grep -P '^\d+$' <<<"$command_results" &>/dev/null; then
            echo "$domain" >>no_bbq_wildcarddomains.txtx
        fi
    done <wildcarddomains.txtx
else
    echo "当前还未获取根域名列表，请执行monitor_wildcard_domain_change.sh脚本" | notify -provider telegram >/dev/null 2>&1
fi
