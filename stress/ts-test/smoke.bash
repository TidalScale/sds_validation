#!/usr/bin/env bash

LOCAL_DISK=""

TEMP_PATH="/tmp"

# bytes
RD_BLOCK=8192
# gibibytes (1024 ** 3)
RD_SIZE=512

STRESS="./stress-ng --temp-path ${TEMP_PATH} --hdd-write-size ${RD_BLOCK} --verify"

stress()
{
    timeout=${1:-10s}
    mem=${2:-80}
    cpu_cnt=`lscpu --parse=cpu | tail -1`
    let "cpu_cnt=($cpu_cnt + 1) / 2"
    #
    # Calculate test_mem
    # Use 80% and spread across 4 working procs
    #
    free_mem=`free -m | awk '/Mem:/{ print $2 }'`
    let "test_mem=$free_mem * $mem / 100"

#    args="--metrics-brief --times --cpu $cpu_cnt --pthread 10 --pthread-max 20 --io 4 --aiol 8 --hdd 4 --vm 8 --vm-bytes ${test_mem}M --timeout $timeout"
    args="--metrics-brief --times --cpu $cpu_cnt --pthread 10 --pthread-max 20 --io 4 --hdd 4 --vm 8 --vm-bytes ${test_mem}M --timeout $timeout"
    echo "${STRESS} $args"
    sudo ${STRESS} $args
}

stress-mem()
{
    timeout=${1:-10s}
    mem=${2:-90}
    cpu_cnt=`lscpu --parse=cpu | tail -1`
    let "cpu_cnt++"
    let "cpu_cnt=$cpu_cnt * 90 / 100"
    #
    # Calculate test_mem
    # Use 90% and spread across cpu
    #
    free_mem=`free -m | awk '/Mem:/{ print $2 }'`
    let "test_mem=$free_mem * $mem / 100"

    args="--metrics-brief --times --vm $cpu_cnt --vm-bytes ${test_mem}M --timeout $timeout"
    echo "stress $args"
    sudo ${STRESS} $args --log-file stress.${timeout}.${mem}.log
}

rdloop()
{
    local i count size amount

    size=${RD_BLOCK:-4096}
    ((amount = ${RD_SIZE:-1} * 1024 ** 3 )) # gibibytes
    ((count = $amount / $size))
    if [[ -e "$LOCAL_DISK" ]]; then
        ((i=0))
        while (( i < 10 ))
        do
            ((i++))
            echo Iteration $i at `date`
            sudo dd if=${LOCAL_DISK} count=${count} bs=${size} | sha256sum
        done
    fi
}

smoke()
{
    timeout=${1:-60m}
    mem=${2:-90}
    rdloop &
    pid=$!
    stress $timeout $mem
    sudo kill $pid
    sudo killall dd
}

run_smoke()
{
    duration=${1:-30m}
    mem=${2:-85}
    smoke $duration $mem
}

duration_test()
{
    date
    run_smoke 15m 45
    date
    run_smoke 30m 45
    date
    run_smoke 45m 45
}

mem_test()
{
    date
    run_smoke 15m 45
    date
    run_smoke 30m 45
    date
    run_smoke 45m 45
    date
    run_smoke 15m 60
    date
    run_smoke 30m 60
    date
    run_smoke 45m 60
    date
    run_smoke 15m 75
    date
    run_smoke 30m 75
    date
    run_smoke 45m 75
}
