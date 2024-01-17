#!/bin/bash

#Latency measurment
echo "===================SEQ1MQ8T1(read)========================"

fio --loops 25 --bs 1m --size 1Gi --ioengine libaio --rw read --name SEQ1MQ8T1_read --direct 1 --numjobs 1 --iodepth 8 --gtod_reduce 0 --runtime 60 --stonewall


echo "===================SEQ1MQ8T1(write)======================="
fio --loops 25 --bs 1m --size 1Gi --ioengine libaio --rw write --name SEQ1MQ8T1_write --direct 1 --numjobs 1 --iodepth 8 --gtod_reduce 0 --runtime 60 --stonewall



echo "===================SEQ128KQ32T1(read)======================="
fio --loops 25 --bs 128k --size 1Gi --ioengine libaio --rw read --name SEQ128KQ32T1_read --direct 1 --numjobs 1 --iodepth 32 --gtod_reduce 0 --runtime 60 --stonewall



echo "===================SEQ128KQ32T1(write)======================="
fio --loops 25 --bs 128k --size 1Gi --ioengine libaio --rw write --name SEQ128KQ32T1_write --direct 1 --numjobs 1 --iodepth 32 --gtod_reduce 0 --runtime 60 --stonewall



echo "===================RANDQ1T1(read)======================="
fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randread --name RANDQ1T1_read --direct 1 --numjobs 1 --iodepth 1 --gtod_reduce 0 --runtime 60 --stonewall



echo "===================RANDQ1T1(write)======================="
fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randwrite --name RANDQ1T1_write --direct 1 --numjobs 1 --iodepth 1 --gtod_reduce 0 --runtime 60 --stonewall



echo "===================RANDQ32T16(read)======================="
fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randread --name RANDQ32T16_read --direct 1 --numjobs 1 --iodepth 32 --gtod_reduce 0 --runtime 60 --stonewall



echo "===================RANDQ32T16(write)======================="
fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randwrite --name RANDQ32T16_write --direct 1 --numjobs 1 --iodepth 32 --gtod_reduce 0 --runtime 60 --stonewall
