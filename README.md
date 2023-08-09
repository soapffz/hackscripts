# 更新日志

## 2023 年 8 月 9 日

### 新增功能

- **src 资产处理脚本**：可以快速将文本文件、csv 等文件正则提取域名、子域名、链接、IP 等内容，方便整理
  - ![执行示例图片](https://img.soapffz.com/soapsgithubimgs/src资产处理脚本执行示例.png)
- **比较老的处理脚本 convert_h1_burpproject_config_to_asset_collector_commands.py**：转换 h1 下载的 burpsuite project config 配置转换为 asset collector 命令行参数输入。现在还适不适用不知道，没有做验证。
- **上传之前的 shell 大工程**：asset collector 的最后一次备份和架构流程图
- **一些远古扫描脚本文件夹**：bak_scan_with_only_httpx、bak_with_naanu_and_httpx
- **print_wildcard_root_domains.py**
- **scan_when_domains_changed.sh**
- **push_xray_to_serverJ.py**
- **monitor_bugbounty_domains**
- **monitor_wildcard_domain_change.sh**
- **monitor_projectdiscovery_data.sh**
- **filter_no_bbq_wildcard_domains.sh**

### 更新

- **基于之前的 asset collector 脚本的工具安装脚本**：优化 debian_vps_install_common_tools.sh

## 2023 年 4 月 11 日

### 初始化

- **debian_vps_install_common_tools.sh 文件**：可以快速在新的 debian vps 上安装常用组件及 hack tools
