#!/bin/bash

rm -f root_domain_of_urls.txtx tmp_compare_results.txtx
if [ -s urls.txtx ]; then
    python3 get_root_domains_linux.py urls.txtx
    sort -u parsed_asset.txt >root_domain_of_urls.txtx
    comm -12 root_domain_of_urls.txtx root_domains_by_chaospy.txtx >tmp_compare_results.txtx
    if [ -s tmp_compare_results.txtx ]; then
        echo "chaospy下载数据中查询到含有bounty的根域名"
        grep -i -f tmp_compare_results.txtx new_download_by_chaospy.txtx >tmp_ogrin_subdomains.txtx
        if [ -s tmp_ogrin_subdomains.txtx ]; then
            echo "查询到对应的子域名及url如下："
            grep -i -f tmp_ogrin_subdomains.txtx urls.txtx
            rm -f tmp_ogrin_subdomains.txtx
        else
            echo "但未查询到子域名，请排查!"
        fi
    else
        echo "chaospy下载数据中未查询到"
    fi
    rm -f tmp_compare_results.txtx
    comm -12 root_domain_of_urls.txtx root_wildcards_domains.txtx >tmp_compare_results.txtx
    if [ -s tmp_compare_results.txtx ]; then
        echo "发现存在bounty的泛解析域名，泛解析域名及url如下,请排查："
        grep -i -f tmp_compare_results.txtx wildcards_domains_in_bounty_targets_data.txtx
        grep -i -f tmp_compare_results.txtx urls.txtx
    else
        echo "泛解析域名中未发现"
    fi
    rm -f tmp_compare_results.txtx
    comm -12 root_domain_of_urls.txtx domains_in_bounty_targets_data.txtx >tmp_compare_results.txtx
    if [ -s tmp_compare_results.txtx ]; then
        echo "发现bounty_targets_data 域名文件中存在对应域名，对应域名及url如下："
        grep -i -f tmp_compare_results.txtx domains_in_bounty_targets_data.txtx
        grep -i -f tmp_compare_results.txtx urls.txtx
    else
        echo "bounty_targets_data 域名文件中未发现"
    fi
else
    echo "请把需要比较的文件放在urls.txtx中"
fi
