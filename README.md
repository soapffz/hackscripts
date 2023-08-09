# change log

- 2023 年 8 月 9 日：
  - 添加 src 资产处理脚本，可以快速将文本文件、csv 等文件正则提取域名、子域名、链接、IP 等内容，方便整理
    -  ![执行示例图片](https://img.soapffz.com/soapsgithubimgs/src资产处理脚本执行示例.png)
  - 添加比较老的处理脚本：convert_h1_burpproject_config_to_asset_collector_commands.py，转换h1下载的burpsuite project config配置转换为asset collector命令行参数输入。现在还适不适用不知道，没有做验证。
  - 更新：基于之前的asset collector脚本的工具安装脚本，优化debian_vps_install_common_tools.sh
  - 添加：上传之前的shell大工程：asset collector的最后一次备份和架构流程图
  - 添加：一些远古扫描脚本文件夹：bak_scan_with_only_httpx、bak_with_naanu_and_httpx
  - 添加：print_wildcard_root_domains.py
  - 添加：scan_when_domains_changed.sh
  - 添加：push_xray_to_serverJ.py
  - 添加：monitor_bugbounty_domains
- 2023 年 4 月 11 日：
  - 初始化，添加 debian_vps_install_common_tools.sh 文件，可以快速在新的 debian vps 上安装常用组件及 hack tools
