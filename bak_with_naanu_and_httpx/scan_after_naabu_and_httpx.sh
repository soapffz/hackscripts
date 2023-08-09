#!/bin/bash

# 定义变量
newdomains="newdomains.txtx"
newdomains_bak="newdomains.txtx.bak"
tmp_need_scan_domains="tmp_need_scan_domains.txtx"
open_domain_url_by_naabu="open_domain_url_by_naabu.txtx"
alive_url_by_httpx="alive_url_by_httpx.txtx"
nuclei_vuln_result="nuclei-vuln-result.txtx"
changelog_scan_domains="changelog_scan_domains.txtx"
changelog_alive_urls="changelog_alive_urls.txtx"
changelog_nuclei_scan_results="changelog_nuclei_scan-results.txtx"
changelog_xray_scanlog="changelog_xray_scanlog.txtx"
all_alive_url="all_alive_url.txtx"

# 定义函数
function notify_start_scan() {
    echo "开始扫描新增域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>$changelog_scan_domains
    echo -e >>$changelog_scan_domains
    echo "开始扫描新增域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
}

function notify_end_scan() {
    echo "扫描结束-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
}

# 主循环
while true; do
    if [ -s $newdomains_bak ] && [ -s $newdomains ]; then
        # 持续监控，比较文件变化
        diff $newdomains $newdomains_bak >$tmp_need_scan_domains
        if [ -s $tmp_need_scan_domains ]; then
            # 如果监控到了newdomains.txtx变化，则将新增部分筛选出来，并将当前newdomains.txtx存为备份，然后才开始扫描
            # 这样就能保证扫描中输入域名不会变化，每次都只监控当前newdomains.txtx即可
            rm -rf $newdomains_bak
            cp $newdomains $newdomains_bak
            rm -rf $newdomains
            notify_start_scan

            # 扫描代码...

            notify_end_scan
        fi
    elif [ -s $newdomains ] && test ! -s $newdomains_bak; then
        # 第一次运行脚本，备份原文件并开始监控
        cp $newdomains $newdomains_bak
    fi
    sleep 10
done
