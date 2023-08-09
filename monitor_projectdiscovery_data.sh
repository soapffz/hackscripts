#!/bin/bash

# 定期使用chaospy获取projectdiscovery项目数据变化并进行通知及调用扫描脚本

# 清理旧的.txt和.zip文件
find . -type f \( -name "*.txt" -o -name "*.zip" \) -delete

# 下载新的数据库
./chaospy.py --download-new >>/dev/null 2>&1
./chaospy.py --download-rewards >>/dev/null 2>&1

if [ -n "$(ls | grep -E '.txt$|.zip$')" ]; then
    unzip '*.zip' >>/dev/null 2>&1
    cat *.txt >>new_download_by_chaospy.txtx
    find . -type f \( -name "*.txt" -o -name "*.zip" \) -delete

    if [ -s new_download_by_chaospy.txtx ]; then
        if [ ! -s alldomains.txtx ]; then
            cp new_download_by_chaospy.txtx alldomains.txtx
            echo "chaospy第一次数据获取成功，共有$(wc -l <alldomains.txtx)条数据-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram
            echo "chaospy第一次数据获取成功-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>changelog_alldomains.txtx
            echo "chaospy第一次数据获取成功-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>changelog_chospy.txtx
        else
            cat new_download_by_chaospy.txtx | anew alldomains.txtx >>new_domains_by_chaospy.txtx
            if [ -s new_domains_by_chaospy.txtx ]; then
                echo "chaospy发现了$(wc -l <new_domains_by_chaospy.txtx)个新域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram
                echo "chaospy发现了$(wc -l <new_domains_by_chaospy.txtx)个新域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>changelog_alldomains.txtx
                echo "chaospy发现了$(wc -l <new_domains_by_chaospy.txtx)个新域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>changelog_chospy.txtx
                cat new_domains_by_chaospy.txtx >>alldomains.txtx
                cat new_domains_by_chaospy.txtx >>newdomains.txtx
            else
                echo "chaospy本次未发现新数据-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" >>changelog_chospy.txtx
            fi
            rm -rf new_domains_by_chaospy.txtx
        fi
    fi
else
    echo "chaospy下载数据失败" | notify -provider telegram >>/dev/null 2>&1
fi
rm -rf new_download_by_chaospy.txtx
