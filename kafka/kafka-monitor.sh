#!/bin/bash
set encoding=utf-8
ulimit -m unlimited
ulimit -v unlimited
ulimit -c unlimited

command="timeout 30 java -Xms100m -Xmx100m -jar ./jmxcmd.jar - 172.19.8.44:9999"
for i in $(cat ./list)
do
    name=$(echo $i | awk -F ":" '{print $2}' | awk -F "," '{print $1}' | awk -F "=" '{print $2}')
    result=$($command $i 2>&1)
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
    echo ${name} ": "${result}
done
