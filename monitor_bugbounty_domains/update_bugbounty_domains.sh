#!/bin/bash

chmod +x ./chaospy.py
while true; do
    rm -rf *.txt *.zip new_download_by_chaospy.txtx domains_in_bounty_targets_data.txtx wildcards_domains_in_bounty_targets_data.txtx root_domains_by_chaospy.txtx root_wildcards_domains.txtx
    ./chaospy.py --download-new >>/dev/null 2>&1
    ./chaospy.py --download-rewards >>/dev/null 2>&1
    if test ! -z "$(ls | grep -E '.txt$|.zip$')"; then
        unzip '*.zip' >>/dev/null 2>&1
        cat *.txt >>new_download_by_chaospy.txtx
        rm -rf *.txt *.zip
        python3 get_root_domains_linux.py new_download_by_chaospy.txtx
        cat parsed_asset.txt | sort | uniq >root_domains_by_chaospy.txtx
        wget -q https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/domains.txt -O - | sort | uniq >domains_in_bounty_targets_data.txtx
        wget -q https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/wildcards.txt -O wildcards_domains_in_bounty_targets_data.txtx
        cat parsed_asset.txt | sort | uniq >root_wildcards_domains.txtx
    else
        echo "chaospy.py下载域名数据失败-$(TZ=UTC-8 date "+%Y%m%d-%H:%M:%S")" | notify -provider telegram >>/dev/null 2>&1
    fi
    sleep 3600
done
