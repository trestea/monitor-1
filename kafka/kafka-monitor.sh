#!/bin/bash
set encoding=utf-8
ulimit -m unlimited
ulimit -v unlimited
ulimit -c unlimited

command="timeout 30 java -Xms100m -Xmx100m -jar ./jmxcmd.jar - localhost:9999"
for i in $(cat /opbin/list)
do
    name=$(echo “$i” | awk -F ":" '{print $2}' | awk -F "," '{print $1}' | awk -F "=" '{print $2}')
    result=$($command “$i” Value 2>&1)
    case $? in
    0)
    result=$(echo “$result” | cut -d ":" -f4|sed 's/^[ \t]*//g')
    ;;
    *)
    result=$($command “$i” OneMinuteRate 2>&1 | cut -d ":" -f4|sed 's/^[ \t]*//g')
    ;;
    esac
    echo ${name} ": "${result}
done
