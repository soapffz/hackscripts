import argparse
import logging
import os
import re
import socket

from urllib.parse import urlparse

import pandas as pd
import tldextract
import publicsuffix2

import urllib3

urllib3.disable_warnings()

logger = logging.getLogger(__name__)


def extract_domain(domain_string):
    """提取域名和根域名，如果无法提取，返回两个空字符串"""

    match = re.search(r"((?:[a-zA-Z0-9-]{1,63}\.){1,}[a-zA-Z]{2,63})", domain_string)
    if match:
        domain_string = match.group(0)
        domain_string = domain_string.lstrip(".")

        domain, tld = publicsuffix2.get_sld(domain_string), publicsuffix2.get_tld(
            domain_string
        )
        if not domain or not tld:
            return "", ""

        if "http" in domain_string:
            domain = urlparse(domain_string).netloc
            if domain and bool(re.search(r"[a-zA-Z]", domain)):
                domain = domain.split(":")[0] if ":" in domain else domain
                return process_domain(domain.replace("www.", ""))
        else:
            domain_string = (
                domain_string.split(":")[0] if ":" in domain_string else domain_string
            )
            return process_domain(domain_string.replace("www.", ""))
    return "", ""


def process_domain(domain):
    """移除可能出现在域名开始的"*."，然后提取出根域名"""
    # Remove leading "*."
    domain = domain.lstrip("*.")
    # If the domain starts with ".", remove it
    if domain.startswith("."):
        domain = domain[1:]
    root_domain = tldextract.extract(domain).registered_domain
    return domain, root_domain


def add_http_to_url(line):
    """在URL前添加"http://"前缀"""
    return "http://{}".format(line)


def extract_url(url):
    """通过正则表达式提取URL，并获取其域名和根域名"""
    re_url = re.findall(
        re.compile(
            r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
        ),
        url,
    )
    if re_url and "." in re_url[0]:
        if "***" not in re_url[0]:
            return re_url[0], extract_domain(re_url[0])
    return url, ("", "")


def process_line(line, subdomain_set, root_domain_set, ip_set, url_set):
    """处理每行文本，提取IP、URL和域名，然后添加到相应的集合中"""
    for part in re.split("[、,***]", line):
        part = part.strip()
        if not part:
            continue
        re_http = re.findall(r"http[s]?://", part)
        re_ip = re.findall(r"(?:[0-9]{1,3}\.){3}[0-9]{1,3}", part)
        if not re_http and not re_ip and "." in part:
            domain, root_domain = extract_domain(part)
            if domain:
                subdomain_set.add(domain)
                root_domain_set.add(root_domain)
                url_set.add(add_http_to_url(domain))
        elif re_http and not re_ip and "." in part:
            re_url_list = re.sub("http", " http", part).split()
            for url in re_url_list:
                url, (domain, _) = extract_url(url.strip())
                if url:
                    url_set.add(url)
                if domain:
                    subdomain_set.add(domain)
        elif re_http and re_ip and "." in part:
            ip_set.update(re_ip)
            url_set.add(part)
        elif not re_http and re_ip and "." in part:
            ip_set.update(re_ip)
            if ":" in part:
                re_ip_port = re.findall(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}\:\d+", part)
                for ip_port in re_ip_port:
                    url_set.add(add_http_to_url(ip_port))


def read_file(file_path):
    """定义一个函数，根据文件的扩展名来读取文件"""
    _, ext = os.path.splitext(file_path)
    if ext == ".txt":
        with open(file_path, "r") as f:
            return f.read()
    elif ext == ".xlsx":
        return pd.read_excel(file_path).to_string(index=False)
    elif ext == ".csv":
        return pd.read_csv(file_path).to_string(index=False)
    elif ext == ".json":
        return pd.read_json(file_path).to_string(index=False)
    else:
        raise ValueError(f"Unsupported file extension: {ext}")


def process_asset(filepath):
    """创建四个集合用于保存子域名、根域名、IP和URL，根据文件类型读取内容，移除所有中文字符和中文标点符号，处理每行文本，对IP列表进行排序，创建结果字符串，并将其保存到文件中"""
    subdomain_set = set()
    root_domain_set = set()
    ip_set = set()
    url_set = set()

    try:
        # 读取文件内容
        content = read_file(filepath)
    except Exception as e:
        print(f"Error reading file: {e}")
        return

    content_without_chs = re.sub("[\u4e00-\u9fa5]", "", content)
    content_without_chs_punctuation = re.sub("[{}]", "", content_without_chs)
    line_list = re.split(r"[、，。！？：；“”‘’]", content_without_chs_punctuation)
    line_list = [line.lower() for line in line_list if "." in line]

    for line in line_list:
        process_line(line, subdomain_set, root_domain_set, ip_set, url_set)

    ip_list = sorted(list(ip_set), key=socket.inet_aton)

    results_content = []
    results_content.append(
        "------------------Root domain list as follows------------------"
    )
    root_domain_set = set(x.strip() for x in root_domain_set if x.strip())  # 过滤空字符串

    results_content.append("\n".join(sorted(root_domain_set)))
    results_content.append(
        "------------------Subdomain list as follows------------------"
    )
    results_content.extend(sorted(subdomain_set))
    results_content.append("------------------IP list as follows------------------")
    results_content.extend(ip_list)
    results_content.append("------------------URL list as follows------------------")
    results_content.extend(sorted(url_set))

    results_save_path = "parsed_asset.txt"
    if os.path.exists(results_save_path):
        os.remove(results_save_path)
    with open(results_save_path, "a+") as f:
        f.write("\n".join(results_content).strip())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("filepath", help="Path to the text file.")
    args = parser.parse_args()
    process_asset(args.filepath)
