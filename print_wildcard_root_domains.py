import json
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

# 下载hackerone数据解析并打印通配符域名的根域名

h1_data = requests.get(
    "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/hackerone_data.json",
    timeout=30,
    verify=False,
)
result = json.loads(h1_data.text)

for record in result:
    for target in record["targets"]["in_scope"]:
        if target["asset_type"] == "URL" and target["asset_identifier"].startswith(
            "*."
        ):
            print(target["asset_identifier"][2:])
