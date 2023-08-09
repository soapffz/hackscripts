#!/bin/bash

while true; do
    if [ -s newdomains.txtx.bak ] && [ -s newdomains.txtx ]; then
        diff newdomains.txtx newdomains.txtx.bak >tmp_need_scan_domains.txtx
        if [ -s tmp_need_scan_domains.txtx ]; then
            echo "筛选出$(wc -l <tmp_need_scan_domains.txtx)条新增域名,开始扫描新增域名-$(date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
            echo "开始扫描新增域名-$(date "+%Y%m%d-%H:%M:%S")" >>changelog_scan_domains.txtx
            echo -n >>changelog_scan_http_urls.txtx
            mv newdomains.txtx newdomains.txtx.bak

            httpx -silent -stats -l tmp_need_scan_domains.txtx -fl 0 -mc 200,302,403,404,204,303,400,401 -o alive_url_by_httpx.txtx >>/dev/null 2>&1
            wait
            if [ -s alive_url_by_httpx.txtx ]; then
                echo "httpx共找到存活资产$(wc -l <alive_url_by_httpx.txtx) 个-$(date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
                alive_url_by_httpx.txtx >>all_http_urls.txtx
                echo "httpx共找到存活资产$(wc -l <alive_url_by_httpx.txtx) 个-$(date "+%Y%m%d-%H:%M:%S")" >>changelog_all_http_urls.txtx
                echo -n >>changelog_all_http_urls.txtx

                nuclei -silent -update
                nuclei -silent -ut
                wait
                cat alive_url_by_httpx.txtx | nuclei -rl 300 -bs 35 -c 30 -mhe 10 -ni -o nuclei-vuln-result.txtx -stats -silent -severity critical,medium,high,low | notify -provider telegram >>/dev/null 2>&1
                wait
                echo "新增$(wc -l <nuclei-vuln-result.txtx)条nuclei扫描结果-$(date "+%Y%m%d-%H:%M:%S")" >>changelog_nuclei_scan-results.txtx
                echo -n >>changelog_nuclei_scan-results.txtx
                >nuclei-vuln-result.txtx
                echo "nuclei扫描结束-$(date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
                使用xray扫描，需要配置webhook开启推送服务
                echo "开始调用xray扫描-$(date "+%Y%m%d-%H:%M:%S")" >>changelog_xray_scanlog.txtx
                echo -n >>changelog_xray_scanlog.txtx
                ./xray_linux_amd64 webscan --basic-crawler --url-file alive_url_by_httpx.txtx --webhook-output http://127.0.0.1:5000/webhook --html-output xray-new--$(date "+%Y%m%d-%H:%M:%S").html
                echo "xray扫描结束-$(date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
                echo "xray扫描结束-$(date "+%Y%m%d-%H:%M:%S")" >>changelog_xray_scanlog.txtx
                echo -n >>changelog_xray_scanlog.txtx
                >alive_url_by_httpx.txtx
            else
                echo "httpx未获取到存活开放端口资产，扫描停止-$(date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
            fi
        fi
    elif [ -s newdomains.txtx ] && test ! -s newdomains.txtx.bak; then
        cp newdomains.txtx newdomains.txtx.bak
    fi
    wait
    sleep 10
done
