#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import requests, json, socket, sys, time, threading, datetime
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

arl_url = 'https://xxxxxx:5003/'
username = 'admin'
password = 'xxxxxx'
sleep_time = 3600
get_size = 100
awvs_url = 'https://xxxxx:3443'
key = 'xxxxxxx'
profile_id = '11111111-1111-1111-1111-111111111111'
headers2 = {'Content-Type': 'application/json', "X-Auth": key}
webhook_url = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxx'
Token = ''
ids = []
target_set = set()
task_dict = {}

def request_handler(url, method='get', data=None, headers=None, timeout=30, verify=False):
    try:
        if method == 'get':
            response = requests.get(url, headers=headers, timeout=timeout, verify=verify)
        elif method == 'post':
            response = requests.post(url, data=json.dumps(data), headers=headers, timeout=timeout, verify=verify)
        return response
    except Exception as e:
        print('请求出错了', e)
        return None

def target_scan(url, target_id):
    global awvs_url, key, profile_id, headers2
    data = {"target_id": target_id, "profile_id": profile_id, "incremental": False,
            "schedule": {"disable": False, "start_date": None, "time_sensitive": False}}
    response = request_handler(awvs_url + '/api/v1/scans', 'post', data, headers2)
    if response and 'profile_id' in response.text and 'target_id' in response.text:
        print(target_id, '添加到AWVS扫描成功', url, datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

def add_target(url, description='ARL-AUTO'):
    global awvs_url, key, profile_id, headers2
    post_data = {"targets": [{"address": url, "description": description}], "groups": []}
    add_log = request_handler(awvs_url + '/api/v1/targets/add', 'post', post_data, headers2)
    if add_log:
        target_id = json.loads(add_log.content.decode())
        target_scan(url, target_id['targets'][0]['target_id'])

def push_wechat_group(content):
    global webhook_url
    resp = request_handler(webhook_url, 'post', {"msgtype": "markdown", "markdown": {"content": content}})
    if resp:
        print(content)
        if 'invalid webhook url' in resp.text:
            print('企业微信key 无效,无法正常推送')
            sys.exit()
        if resp.json()["errcode"] != 0:
            raise ValueError("push wechat group failed, %s" % resp.text)

def message_push():
    while True:
        time.sleep(10)
        get_target_url = awvs_url + '/api/v1/vulnerability_types?l=100&q=status:open;severity:3;'
        r = request_handler(get_target_url, 'get', headers=headers2)
        if r:
            result = json.loads(r.content.decode())
            init_high_count = sum(xxxx['count'] for xxxx in result['vulnerability_types'])
            print('当前高危:', init_high_count)
            while True:
                time.sleep(10)
                r2 = request_handler(get_target_url, 'get', headers=headers2)
                if r2:
                    result = json.loads(r2.content.decode())
                    high_count = sum(xxxx['count'] for xxxx in result['vulnerability_types'])
                    if high_count != init_high_count:
                        current_date = strftime("%Y-%m-%d %H:%M:%S", gmtime())
                        message_push = str(socket.gethostname()) + '\n' + current_date + '\n'
                        for xxxx in result['vulnerability_types']:
                            message_push += '漏洞: ' + xxxx['name'] + '数量: ' + str(xxxx['count']) + '\n'
                        print(message_push)
                        push_wechat_group(message_push)
                        init_high_count = high_count
                    else:
                        init_high_count = high_count

threading.Thread(target=message_push,).start()

while True:
    try:
        data = {"username": username, "password": password}
        headers = {'Content-Type': 'application/json; charset=UTF-8'}
        logreq = request_handler(arl_url + '/api/user/login', 'post', data, headers)
        if logreq:
            result = json.loads(logreq.content.decode())
            if result['code'] == 401:
                print(data, '登录失败')
                sys.exit()
            if result['code'] == 200:
                print(data, '登录成功', result['data']['token'])
                Token = result['data']['token']
            headers = {'Token': Token, 'Content-Type': 'application/json; charset=UTF-8'}
            print('开始获取最近侦察资产')
            req = request_handler(arl_url + '/api/task/?page=1&size=' + str(get_size), 'get', headers=headers)
            if req:
                result = json.loads(req.content.decode())
                ids = [xxx['_id'] for xxx in result['items'] if xxx['status'] == 'done']
                data = {"task_id": ids}
                req2 = request_handler(arl_url + '/api/batch_export/site/', 'post', data, headers)
                if req2 and '"not login"' in req2.text:
                    ids = []
                    continue
                target_list = req2.text.split()
                add_list = target_set.symmetric_difference(set(target_list))
                current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S').replace(' ', '-').replace(':', '-')
                for xxxx in add_list:
                    if xxxx in target_list:
                        target_set.add(xxxx)
                        task_dict[xxxx] = 'ARL-' + current_time
                        add_target(xxxx.strip(), 'ARL-' + current_time)
                        print(xxxx)
                time.sleep(int(sleep_time))
                Token = ''
                ids = []
    except Exception as e:
        print(e, '出错了，请排查')