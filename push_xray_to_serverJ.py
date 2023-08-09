# -*-coding: utf-8 -*-
from flask import Flask, request
import requests
import logging
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

app = Flask(__name__)

VULN_TYPES = ['nginx-wrong-resolve', 'pprof', '2021-2949', 'dedecms', '2021-28164', 'iflytek', 'dirscan/sensitive/crossdomain']

def push_to_serverJ(content):
    try:
        paramsGet = {"desp": content, "title": "xray漏洞推送"}
        requests.get("https://sctapi.ftqq.com/SCT124525TkVFQVcbsP65mRziKscQASV0W.send/", params=paramsGet)
    except Exception:
        logging.exception("Error pushing to serverJ")

@app.route('/webhook', methods=['POST'])
def xray_webhook():
    data = request.json
    vuln_data = data.get("data", {})
    detail = vuln_data.get("detail", {})
    if detail:
        content = """xray 发现了新漏洞
**url:** {url}
**插件:** {plugin}
**payload:** {payload}
**httpHead:** {httpHead}
""".format(url=detail.get("addr", ""), plugin=vuln_data.get("plugin", ""), payload=detail.get("payload", ""), httpHead=detail.get("snapshot", [])[0][0])
        if not any(vuln_type in content for vuln_type in VULN_TYPES):
            push_to_serverJ(content)
    return 'ok'

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)