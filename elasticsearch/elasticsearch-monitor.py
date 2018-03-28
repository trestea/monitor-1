#!/usr/bin/python
# @Time    : 2018/3/27 18:10
# @Author  : lipeijing
# @Email   : lipeijing@jd.com

import os
import json
from pprint import pprint
import commands
import socket
import fcntl
import struct

def getip(ethname):
    s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0X8915, struct.pack('256s', ethname[:15]))[20:24])

def isNumber(item):
    try:
        float(item)
        if type(item) == bool:
            return False
        return True
    except Exception as e:
        return False

def list_dic(dic):
    for name, value in dic.items():
        if isinstance(value, dict):
            list_dic(value)
        else:
            if isNumber(value):
                print(name + ":" + str(value))
            else:
                print(name + ":\"" + str(value) + "\"")

if __name__ == "__main__":
    hostname = socket.gethostname()
    ip = socket.gethostbyname(hostname)
    if ip == '127.0.0.1':
        ip = str(getip('eth0'))
    try:
        url = 'http://{ip}:9200/_cluster/health'.format(ip=ip)
        cmd = 'curl -s "{url}"'.format(url=url)
        (status, output) = commands.getstatusoutput(cmd)
        result = json.loads(output)
        list_dic(result)
    except Exception as e:
        print e
