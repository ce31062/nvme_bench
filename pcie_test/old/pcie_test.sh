#!/bin/bash
#difine the log export path

current_directory=$(pwd)

export LOG="$current_directory"/pcie_test.log

if [ "$1" = "help" ]; then
    cat readme.txt
    exit
fi

#Log start
:>$LOG
echo "pcie test start"
echo "script=$0" | tee -a $LOG
echo "argument=$1" | tee -a $LOG
date | tee -a $LOG

echo "------------------------------------------------
Argument:
    latency, l: latency
    help: help
------------------------------------------------------" | tee -a $LOG
   
if [ "$1" = "latency" ] || [ "$1" = "l" ]; then

#Mount
echo "=============================mount==============================" | tee -a $LOG
   
    echo -n "Input device name to mount (ex.nvmeo):" | tee -a $LOG 
        read device   
    echo -n "Input directory name to mount (ex.gen3):" | tee -a $LOG 
        read directory 
        #sudo mkdir /"$directory" | tee -a $LOG   　
	sudo mount /dev/"$device" /"$directory" | tee -a $LOG   
	echo "Complete!" | tee -a $LOG 
    sudo df | tee -a $LOG 
	
	

# Secure Erase
echo "=========================secure erase==============-============" | tee -a $LOG   

echo -n "Do you want to perform secure erase?[y/n]" | tee -a $LOG   
read ANS

case $ANS in
	"" | [Yy]*)
	echo -n "Input device name to secure erase (ex.nvmeo):" | tee -a $LOG   
	read device 
	sudo nvme format /dev/$device | tee -a $LOG   
	echo "Complete!" | tee -a $LOG   
	;;
	*)
	
	echo "Canceled" | tee -a $LOG   
	;;
esac


#Move directory
echo "=================================================================" | tee -a $LOG

        echo -n "Which directry you want to move to(ex.gen3):" | tee -a $LOG 
        read directory

      cd /"$directory"
       
     echo "★Moved to $directory" | tee -a $LOG 
       
echo "==================================================================" | tee -a $LOG

echo "///////Measuring latency///////" | tee -a $LOG
echo "LinuxPC" | tee -a $LOG   


(
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

  ) | tee -a $LOG
 
  
echo "PCIe latency test completed!" | tee -a $LOG


#Remove
cd "$current_directory"

echo "////Finish////" | tee -a $LOG

fi
