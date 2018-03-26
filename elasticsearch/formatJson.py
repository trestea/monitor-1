#!/usr/bin/python3
# -*- coding: utf-8 -*-
# @Time    : 2018/3/26 18:10
# @Author  : lipeijing
# @Email   : lipeijing@jd.com

import os
import json
from pprint import pprint
import subprocess

if __name__ == "__main__":
    (status, output) = subprocess.getstatusoutput("curl -s  'http://172.19.8.43:9200/_cluster/health'")
    result = json.loads(output)
    for item in result:
        print(item + ":" + str(result[item]))
