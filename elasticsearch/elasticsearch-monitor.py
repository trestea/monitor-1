#!/usr/bin/python2
# -*- coding: utf-8 -*-
# @Time    : 2018/3/26 18:10
# @Author  : lipeijing
# @Email   : lipeijing@jd.com

import os
import json
from pprint import pprint
import commands
import socket

if __name__ == "__main__":
    hostname = socket.gethostname()
    ip = socket.gethostbyname(hostname)
    try:
        url = 'http://{ip}:9200/_cluster/health'.format(ip=ip)
        cmd = 'curl --connect-timeout 5 -s "{url}"'.format(url=url)
        (status, output) = commands.getstatusoutput(cmd)
        result = json.loads(output)
        for item in result:
            print item + ":" + str(result[item])
    except Exception as e:
        print e
