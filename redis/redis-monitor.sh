#!/bin/bash
#set -x
PWD=$(dirname $0)
config=${1?}

[ -f /usr/bin/redis-cli ] || {
    nohup yum install -y epel-release >/dev/null 2>&1 &
    nohup yum install -y redis >/dev/null 2>&1 &
}

readonly KEY="monitor_saas_ops"
readonly VALUE="saas_ops"
readonly TTL="2"
readonly COMMAND="redis-cli"
result="-1"
redis_status="-1"

# 往redis中添加一个key，并设置key的过期时间为7秒钟
# 设置过期时间的目的是，避免服务异常不能写入而无法发现
# 增加timeout命令，限制执行时间在5秒内，避免超时卡死
function redis_set_key
{
    timeout 2 $COMMAND -h $SERVER -p $PORT -a $PASSWORD set $KEY $VALUE ex $TTL >/dev/null 2>&1
}

# 从redis中读取一个key
# 增加timeout命令，限制执行时间在5秒内，避免超时卡死
# 取出一个key之后为什么不del掉这个key而是通过过期时间来删除呢？主要是防止del掉这个key的时候，各种异常导致误删除业务上的key
function redis_get_key
{
    result=$(timeout 2 $COMMAND -h $SERVER -p $PORT -a $PASSWORD get $KEY)
}

function check_result
{
    echo "tags: action : ${NAME}_KEY_SET_GET"
    if [ "$result" == "$VALUE" ];then
        echo "status : 1"
    else
        echo "status : 0"
    fi
    echo
}

function check_status
{
    timeout 5 redis-cli -h $SERVER -p $PORT -a $PASSWORD info |\
    egrep -w 'instantaneous_input_kbps|instantaneous_output_kbps|rejected_connections|used_memory|mem_fragmentation_ratio|instantaneous_ops_per_sec'|\
    while read line
    do
        key=$(echo $line | awk -F: '{print $1}')
        value=$(echo $line |awk -F: '{print $2}')

        if [ $key == "mem_fragmentation_ratio" ]; then
            value=$(echo $line |awk -F: '{print $2}' | awk -F: '{printf("%.3f", ($1)*100)}')
        fi

        if [ $key == "used_memory" ];then
            key="memory_used_ratio"
            value=$(echo $line |awk -F: '{print $2}')
            value=$(echo "$value $2"|awk '{printf("%.3f", ($1/$2)*100)}')
        fi

        if [ $key == "instantaneous_output_kbps" ]; then
            echo tags: action : $1_$key
            echo status : $value
            echo
            key="bandwidth_used_ratio"
            value=$(echo $line |awk -F: '{print $2}')
            value=$(echo "$value $4" |awk '{printf("%.3f", ($1/$2)*100)}')
        fi

        echo tags: action : $1_$key
        echo status : $value
        echo
    done
}

function check_latency
{
    latency_bin=$(timeout 3 redis-cli -h $SERVER -p $PORT -a $PASSWORD --latency)
    echo $latency_bin > $PWD/.latency_bin_out
    avg_latency=$(strings $PWD/.latency_bin_out |tail -f -n 1|awk '{print $6}')
    echo "tags: action : ${NAME}_redis_latency"
    echo "status : $avg_latency"
    echo
    rm -f $PWD/.latency_bin_out
}

function main
{
        while read line
        do
            if [ x"$line" == "x" ];then
                break
            fi
            readonly NAME=$(echo $line | awk '{print $1}')
            readonly SERVER=$(echo $line | awk '{print $2}' | awk -F: '{print $1}')
            readonly PORT=$(echo $line | awk '{print $2}' | awk -F: '{print $2}')
            readonly PASSWORD=$(echo $line | awk '{print $3}')
            readonly MEMORY=$(echo $line | awk '{print $4}')
            readonly TOTALCONNECTION=$(echo $line | awk '{print $5}')
            readonly BANDWIDTH=$(echo $line | awk '{print $6}')

            redis_set_key
            redis_get_key
            check_result
            check_status $NAME $MEMORY $TOTALCONNECTION $BANDWIDTH
            check_latency
        done <${config}
}

main

