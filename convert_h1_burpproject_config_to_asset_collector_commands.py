#!/usr/bin/python3
# 转换h1下载的burpsuite project config配置转换为asset collector命令行参数输入
import json
import sys
import re


def extract(host, domain_set):
    domain = re.sub(r"^(\.+|w+\.)|\^|\\\\|\*|\$", "", host)
    domain_set.add(domain)


def extract_url_from_dict_list(dict_list, domain_set):
    for dict in dict_list:
        if dict["enabled"] == True:
            host = dict["host"] if "," not in dict["host"] else dict["host"].split(",")
            if isinstance(host, str):
                extract(host, domain_set)
            else:
                for i in host:
                    extract(i, domain_set)


if __name__ == "__main__":
    try:
        with open(str(sys.argv[1]), "r") as f:
            json_data = json.load(f)["target"]["scope"]
        include_scope_set = set()
        exclude_scope_set = set()
        extract_url_from_dict_list(json_data["include"], include_scope_set)
        extract_url_from_dict_list(json_data["exclude"], exclude_scope_set)
        command = ""
        if include_scope_set:
            command += "-d " + ",".join(include_scope_set)
        if exclude_scope_set:
            command += " -b " + ",".join(exclude_scope_set)
        print("asset collector command options are as follows:\n{}".format(command))
    except Exception as e:
        print("程序报错了:{}".format(e))
