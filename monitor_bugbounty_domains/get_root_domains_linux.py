#!/usr/bin/env python
# 输入文本，输出根域名到parsed_asset.txt，没有进行中文处理及去重，自行操作
import sys
import os
import tldextract

if len(sys.argv) != 2:
    print("还没指定文件！")
    exit(0)

results_save_path = "parsed_asset.txt"
if os.path.isfile(results_save_path):
    os.remove(results_save_path)

with open(str(sys.argv[1]), "r", encoding="utf-8") as f1:
    with open(results_save_path, "a+") as f2:
        for line in f1:
            line = line.strip()
            if "." in line:
                root_domain = tldextract.extract(line).registered_domain
                if root_domain:
                    f2.write(root_domain + "\n")