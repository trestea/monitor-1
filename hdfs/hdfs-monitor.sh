#!/bin/bash
# echo xdata > xdata
# ./hadoop fs -mkdir /monitor 
# ./hadoop fs -copyFromLocal ./xdata /monitor/

result=$(timeout 30 /export/App/hadoop-2.6.1/bin/hadoop fs -cat /monitor/xdata 2>/dev/null)
if [ "$result" = "xdata" ];then
    echo "hdfs_read:0"
else
    echo "hdfs_read:1"
fi

