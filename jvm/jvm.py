#!/usr/bin/python
# -*- coding: utf-8 -*-
# @Time    : 2018/4/20 11:16
# @Author  : lipeijing
# @Email   : lipeijing@jd.com

import json
import sys
import commands


def get_pid(app):
    cmd = '/export/App/jdk1.8.0_60/bin/jps'
    (status, output) = commands.getstatusoutput(cmd=cmd)
    if status == 0:
        list = output.split('\n')
        for i in list:
            if app in i:
                pid = i.split()[0]
                return pid
        else:
            print("es_status_error:" + str(1))
            exit(1)
    else:
        print("jps_error:" + str(1))
        exit(2)


def run_command(pid):
    cmd = '/export/App/jdk1.8.0_60/bin/jstat -gcutil ' + pid
    (status, output) = commands.getstatusoutput(cmd=cmd)
    if status == 0:
        return output
    else:
        print("jstat_error:" + str(1))
        exit(3)


def isNumber(item):
    try:
        float(item)
        if type(item) == bool:
            return '"' + item + '"'
        return item
    except Exception as e:
        return '"' + item + '"'


def format_output(output, app):
    desclist = ['Heap上的Survivor space 0区已使用空间的百分比', 'Heap上的Survivor space 1区已使用空间的百分比', 'Heap上的Eden space区已使用空间的百分比',
            'Heap上的Old space区已使用空间的百分比', '元数据区使用比例', '压缩使用比例', '从应用程序启动到采样时发生Young GC的次数',
            '应用程序启动到采样时Young GC所用的时间(单位秒)', '从应用程序启动到采样时发生Full GC的次数', '从应用程序启动到采样时Full GC所用的时间(单位秒)',
            '从应用程序启动到采样时用于垃圾回收的总时间(单位秒)']
    outputlist = output.split('\n')
    key = outputlist[0].split()
    value = outputlist[1].split()
    for i in range(11):
        # print("tags: app: %s") %(app)
        print(key[i] + ":" + (isNumber(value[i])) + ",desc:" + desclist[i])


def check_app_status(app):
    pid = get_pid(app)
    output = run_command(pid)
    format_output(output, app)


def check_app(apps):
    for app in apps:
        check_app_status(app)


if __name__ == '__main__':
    apps = ['Elasticsearch', ]
    check_app(apps)

