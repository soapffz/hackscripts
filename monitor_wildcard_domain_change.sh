#!/bin/bash

# 该文件使用tmux开个线程然后循环半小时执行一次即可：while true; do ./monitor_wildcard_domain_change.sh;sleep 3600; done
# 调用print_wildcard_domain_from_arkadiyt.py脚本获取根域名数据，发现有变动则将新域名添加到wildcarddomains.txtx中，并且添加到changelog_wildcarddomain.txtx最后
python3 print_wildcard_domain_from_arkadiyt.py >newdownload_wildcard.txtx
if [ -s newdownload_wildcard.txtx ]; then
    if test ! -s wildcarddomains.txtx; then
        # 如果该文件不存在，则将当前下载列为wildcarddomains.txtx
        mv newdownload_wildcard.txtx wildcarddomains.txtx
        echo -e "第一次根域名数据添加成功\n" >>changelog_wildcarddomain.txtx
        echo "第一次根域名数据添加成功-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >/dev/null 2>&1
    else
        # 如果文件存在，则进行比较
        anew newdownload_wildcard.txtx wildcarddomains.txtx >new_wildcarddomaindomains.txtx
        if [ -s new_wildcarddomaindomains.txtx ]; then
            # 如果有新增的域名，则添加到最后
            cat new_wildcarddomaindomains.txtx >>wildcarddomains.txtx
            echo -e "添加新的根域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")\n" >>changelog_wildcarddomain.txtx
            cp new_wildcarddomaindomains.txtx changelog_wildcarddomain.txtx
            echo "bounty-targets-data新增了$(wc -l <new_wildcarddomaindomains.txtx)条根域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >/dev/null 2>&1
        else
            echo -e "bounty-targets-data未获取到新的根域名-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")\n" >>changelog_wildcarddomain.txtx
        fi
        rm new_wildcarddomaindomains.txtx
    fi
else
    echo "arkadiyt/bounty-targets-data数据更新失败-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >/dev/null 2>&1
fi
rm newdownload_wildcard.txtx
rm *.json
