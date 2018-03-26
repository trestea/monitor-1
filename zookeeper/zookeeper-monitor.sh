#!/bin/sh
set encoding=utf-8
ip=127.0.0.1
port=2181

last=$(timeout 30 echo srvr| nc -w 3 $ip $port | awk '/(Received|Sent):/{print $2}')
sleep 1
now=$(timeout 30 echo srvr| nc -w 3 $ip $port | awk '/(Received|Sent):/{print $2}')
if [ -z "$last" ] || [ -z "$now" ];then
   echo "ZK_received:-1"
   echo "ZK_sent:-1"
   exit 1
fi

received_now=$(echo $now | awk '{print $1}')
received_last=$(echo $last | awk '{print $1}')
sent_now=$(echo $now |awk '{print $2}')
sent_last=$(echo $last |awk '{print $2}')
echo "ZK_received:"$(($received_now-$received_last))
echo "ZK_sent:"$(($sent_now-$sent_last))

#follower is 0,leader is 1
timeout 30 echo stat | nc -w 3 $ip $port | awk '{if ($0~"^Mode:.*follower"){print "ZK_mode:1"};if($0~"^Mode:.*leader"){print "ZK_mode:0"};if($0~"^Node count:.*"){print "ZK_node:"$NF}}'


size=$(timeout 30 find /export/Data/zookeeper/version-2/ -name "snapshot*"  -mtime -1 -type f | xargs ls -lt | head -1| awk '{ print $5}')
echo "ZK_snapshota_size:$size"
