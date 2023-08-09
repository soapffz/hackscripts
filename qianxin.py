#-*-coding:utf-8-*-
import re
import requests
import time
import warnings
import base64

def main():
    warnings.filterwarnings('ignore')  # 忽略SSL警告
    Authorization=input("请登录后输入Authorization:")
    print ("输入搜索关键字：")
    key=input()
    bkey=base64.b64encode(key.encode()).decode().replace('+','-')
    num=[]
    url='https://hunter.qianxin.com/api/search'
    ret=pqpqge(url,num,bkey,Authorization)
    print(ret)
    i=ret[0]
    rem=ret[1]
    jl=[]
    if i>=0 and i<8:
        numm=0
        length=int(256/(2**(i+1)))
        for j in range(0,256,length):
            time.sleep(2)
            if numm<2*rem:
                print(j)
                keys=key+'&&ip="'+str(j)+'.0.0.0/'+str(i+1)+'"'
                print (keys)
                pq(keys,Authorization)
            else:
                jl.append(j)
                break
            numm=numm+1
        length=int(256/(2**i))
        for j in range(jl[0],256,length):
            keys=key+'&&ip="'+str(j)+'.0.0.0/'+str(i+1)+'"'
            print (keys)
            pq(keys,Authorization)
            time.sleep(2)
    elif i>=8 and i<16:
        length=int(256/(2**(i-8)))
        for k in range(0,256):
            for j in range(0,256,length):
                keys=key+'&&ip="'+str(k)+'.'+str(j)+'.0.0/'+str(i)+'"'
                print (keys)
                pq(keys,Authorization)
    elif i>=16 and i<24:
        length=int(256/(2**(i-16)))
        for k in range(0,256):
            for m in range(0,256):
                for j in range(0,256,length):
                    keys=key+'&&ip="'+str(k)+'.'+str(m)+'.'+str(j)+'.0/'+str(i)+'"'
                    print (keys)
                    pq(keys,Authorization)
    elif i>=24 and i<32:
        length=int(256/(2**(i-24)))
        for k in range(0,256):
            for m in range(0,256):
                for n in range(0,256):
                    for j in range(0,256,length):
                        keys=key+'&&ip="'+str(k)+'.'+str(m)+'.'+str(n)+'.'+str(j)+'/'+str(i)+'"'
                        print (keys)
                        pq(keys,Authorization)
    try:
        input("请输入任意键按回车结束！")
    except:
        pass

def pqpqge(url,num,bkey,Authorization):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Content-Type': 'application/json',
        'Content-Length': '162',
        'Origin': 'https://hunter.qianxin.com',
        'Authorization': Authorization,
        'Connection': 'close',
        'Referer': 'https://hunter.qianxin.com/home/list?search=title%253D%2522gitlab%2522',
        'Cookie': bkey,
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        }
    body='{"search":"'+bkey+'","page_size":10,"page":1,"start_time":"","end_time":"","is_web":"1","status_code":"200","syntax_condition":[]}'
    response = requests.post(url,body,headers = headers,timeout=20,verify=False)
    result=response.text
    print (result)
    page=int(int(re.findall(r'total":(.+?),', result)[0])/10)
    print ("总共"+str(page)+"页")
    print("请输入您想爬取多少页，建议少一点哦亲！！")
    page=int(input())
    ret=[]
    for i in range(0,30):
        if int(page)>=2**i and int(page)<2**(i+1):
            ret.append(i)
            ret.append(page-2**i)
            return ret
            break

def pq(key,Authorization):
    bkey=base64.b64encode(key.encode()).decode().replace('+','-')
    url='https://hunter.qianxin.com/api/search'
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Content-Type': 'application/json',
        'Authorization': Authorization,
        'Content-Length': '162',
        'Origin': 'https://hunter.qianxin.com',
        'Connection': 'close',
        'Referer': 'https://hunter.qianxin.com/home/list?search=title%253D%2522gitlab%2522',
        'Cookie': bkey,
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        }
    body='{"search":"'+bkey+'","page_size":10,"page":1,"start_time":"","end_time":"","is_web":"1","status_code":"200","syntax_condition":[]}'
    response = requests.post(url,body,headers = headers,timeout=20,verify=False)
    result=response.text
    iplist=re.findall(r'ip":"(.+?)"', result)
    portlist=re.findall(r'"port":"(.+?)"', result)
    protocollist=re.findall(r'"protocol":"(.+?)"', result)
    f=open("qianxinresult.txt",'a')
    for i in range(len(iplist)):
            print(protocollist[i]+'://'+iplist[i]+':'+portlist[i]+'\n')
            f.write(protocollist[i]+'://'+iplist[i]+':'+portlist[i]+'\n')
    f.close()

def logo():
    print('''
        _                      _                                    
       (_)                    (_)                                   \r
  __ _  _   __ _  _ __  __  __ _  _ __    ___  _ __  ___   ___  ___ \r
 / _` || | / _` || '_ \ \ \/ /| || '_ \  / __|| '__|/ _ \ / __|/ __|\r
| (_| || || (_| || | | | >  < | || | | || (__ | |  | (_) |\__ \\\\__ \\\r
 \__, ||_| \__,_||_| |_|/_/\_\|_||_| |_| \___||_|   \___/ |___/|___/\r
    | |                                                             \r
    |_|                                                             \r
\r
\r
                                       --by:DSB v1.0           \r
''')

if __name__=="__main__":
    logo()
    main()