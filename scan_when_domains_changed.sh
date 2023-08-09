#!/bin/bash

# 后台持续监控newhttpurls.txtx变化，如果变化了则扫描
# 第一次先将当前newhttpurls.txtx进行备份，然后每10秒比较一次newhttpurls.txtx与备份文件的差异，如果变化了则只扫描变化的部分，扫描前将合并的所有内容覆盖原来的备份文件，扫描后继续监控newhttpurls.txtx文件变化

while true; do
    DATE=$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")
    if [ -s newhttpurls.txtx.bak ] && [ -s newhttpurls.txtx ]; then
        # 持续监控，比较文件变化
        cat newhttpurls.txtx | anew newhttpurls.txtx.bak >>tmp_need_scan_http_urls.txtx
        if [ -s tmp_need_scan_http_urls.txtx ]; then
            # 如果监控到了newhttpurls.txtx变化，则将新增部分筛选出来，并将当前newhttpurls.txtx存为备份，然后才开始扫描
            # 这样就能保证扫描中输入域名不会变化，每次都只监控当前newhttpurls.txtx即可
            rm -f newhttpurls.txtx.bak
            cp newhttpurls.txtx newhttpurls.txtx.bak
            rm -f newhttpurls.txtx
            echo "筛选出$(wc -l <tmp_need_scan_http_urls.txtx)条新增待扫描链接,开始扫描新增链接-$DATE" | notify -provider telegram >>/dev/null 2>&1
            echo "开始扫描新增链接-$DATE" >>changelog_scan_http_urls.txtx
            echo -e >>changelog_scan_http_urls.txtx

            # 从这里开始使用漏洞扫描工具开始进行扫描
            nuclei -silent -update
            nuclei -silent -ut
            wait
            cat tmp_need_scan_http_urls.txtx | nuclei -c 30 -mhe 10 -ni -o nuclei-vuln-result.txtx -stats -silent -severity critical,medium,high,low | notify -provider telegram >>/dev/null 2>&1
            wait
            echo -e >>changelog_nuclei_scan-results.txtx
            if [ -s nuclei-vuln-result.txtx ]; then
                echo "新增$(wc -l <nuclei-vuln-result.txtx)条nuclei扫描结果-$DATE" >>changelog_nuclei_scan-results.txtx
                cat nuclei-vuln-result.txtx >>changelog_nuclei_scan-results.txtx
                echo "nuclei有新的扫描结果，可登录服务器查看，扫描结束-$DATE" | notify -provider telegram >>/dev/null 2>&1
            else
                echo "nuclei没有发现新的扫描结果，扫描结束-$DATE" | notify -provider telegram >>/dev/null 2>&1
                echo "nulcei没有发现新的扫描结果，扫描结束-$DATE" >>changelog_nuclei_scan-results.txtx
                echo -e >>changelog_nuclei_scan-results.txtx
            fi
            rm -f nuclei-vuln-result.txtx
            # #使用xray扫描，需要配置webhook开启推送服务
            echo "开始调用xray扫描" >>changelog_xray_scanlog.txtx
            echo -e >>changelog_xray_scanlog.txtx
            ./xray_linux_amd64 webscan --url-file tmp_need_scan_http_urls.txtx --webhook-output http://127.0.0.1:5000/webhook --html-output xray-new--$DATE.html
            echo "xray扫描结束，如需查看报告请上服务器查看" | notify -provider telegram >>/dev/null 2>&1
            echo "xray扫描结束-$DATE" >>changelog_xray_scanlog.txtx
            echo -e >>changelog_xray_scanlog.txtx
            rm -f tmp_need_scan_http_urls.txtx
        fi
    elif [ -s newhttpurls.txtx ] && test ! -s newhttpurls.txtx.bak; then
        # 第一次运行脚本，备份原文件并开始监控
        cp newhttpurls.txtx newhttpurls.txtx.bak
    fi
    wait
    sleep 10
done
