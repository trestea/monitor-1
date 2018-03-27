#!/usr/bin/python
# coding=utf-8
# @Time    : 2018/3/27 18:10
# @Author  : lipeijing
# @Email   : lipeijing@jd.com

from __future__ import unicode_literals
import os
import json
from pprint import pprint
import commands
import socket

def isNumber(item):
    try:
        float(item)
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
                print(name + ": \"" + value + "\"")

if __name__ == "__main__":
    hostname = socket.gethostname()
    ip = socket.gethostbyname(hostname)
    url = 'http://{ip}:9200/_cluster/health'.format(ip=ip)
    cmd = 'curl -s "{url}"'.format(url=url)
    (status, output) = commands.getstatusoutput(cmd)
    result = json.loads(output)
    list_dic(result)
