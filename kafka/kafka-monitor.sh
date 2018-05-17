#!/bin/bash
set encoding="utf-8"
ulimit -m unlimited
ulimit -v unlimited
ulimit -c unlimited

JAVA="/export/App/jdk1.8.0_60/bin/java"
HOST_IP=$(ifconfig eth0 | grep -P "inet (\d+)\.(\d+)\.(\d+)\.(\d+)" -o | grep -P "(\d+)\.(\d+)\.(\d+)\.(\d+)" -o)
LIST="/opbin/list"
JMX_JAR="/opbin/jmxcmd.jar"

command="timeout 30 $JAVA -Xms100m -Xmx100m -jar $JMX_JAR - $HOST_IP:9999"
for i in $(cat $LIST)
do
    name=$(echo $i | awk -F ":" '{print $2}' | awk -F "," '{print $1}' | awk -F "=" '{print $2}')
    result=$($command $i 2>&1)
    case $? in
    0)
    case ${result} in
    *Value*)
    result=$($command $i Value 2>&1 | cut -d ":" -f4|sed 's/^[ \t]*//g')
    ;;
    *OneMinuteRate*)
    result=$($command $i OneMinuteRate 2>&1 | cut -d ":" -f4| sed 's/^[ \t]*//g')
    ;;
    *)
    result="参数错误!"
    esac
    result=${result:0:5}
    echo ${name} ": "${result}
    ;;
    *)
    echo "ScriptStatus : 1"
    exit 1
    ;;
    esac
done
echo  "ScriptStatus : 0"
