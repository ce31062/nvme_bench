#!/bin/bash
version="3.0"

#global variables
declare -g directory
declare -g current_directory

if [ "$1" == "test" ]; then	
    echo "hello world"
fi


#log export path
    current_directory=$(pwd)
    case "$1" in
    throughput | t )
        export LOG="$current_directory"/pcie_throughput.log
        ;;
        latency | l )
        export LOG="$current_directory"/pcie_latency.log
        ;;
        all | a )
        export LOG="$current_directory"/pcie_all.log
        ;;
        help | h )
        cat readme_all.txt
        exit 0
        ;;
        *)
        echo "invalid argument!!"
        exit 0
        ;;    
    esac
     
#Log start
    :>$LOG
        echo "pcie test start"
        echo "script=$0" | tee -a $LOG
        echo "argument=$1" | tee -a $LOG
        echo "version=$version" | tee -a $LOG
        date | tee -a $LOG

        echo "------------------------------------------------
        Argument:
            secure_erase, s: secure erase
            throughput,t: throuput
            latency, l: latency
            all, a: latency & throughput
            help, h: help
        ------------------------------------------------------" | tee -a $LOG	

#Mount
    echo "=============================mount==============================" | tee -a $LOG
        
        echo -n "Input device name (ex.nvme0n1):" | tee -a $LOG 
        read device   
        sudo mount /dev/"$device" /test_bench | tee -a $LOG   
        echo "Complete!" | tee -a $LOG 
        sudo df | tee -a $LOG 

#Secure Erase
    echo "=========================secure erase==============-============" | tee -a $LOG   

    echo -n "Execute secure erase?[y/n]" | tee -a $LOG   
    read ANS
    case $ANS in
        "" | [Yy]*)
        echo -n "Input device name to secure erase (ex.nvme0n1):" | tee -a $LOG   
        read device 
        sudo nvme format /dev/$device | tee -a $LOG   
        echo "Complete!" | tee -a $LOG   
        ;;
        *)
        echo "Canceled" | tee -a $LOG   
        ;;
    esac

#Move directory
    if [[ "$1" != "secure_erase" && "$1" != "s" ]]; then	
        echo "=================================================================" | tee -a $LOG
        cd /test_bench
        echo "Moved to test_bench directory" | tee -a $LOG 

        echo "Start measurement after 5sec.Please wait..."
        sleep 5
        
        echo "==================================================================" | tee -a $LOG

	echo "/////  Start measurement!  /////" | tee -a $LOG
        echo "LinuxPC" | tee -a $LOG  
    fi 
#====================Throughput=======================  
    if [[ "$1" == "throughput" || "$1" == "t" || "$1" == "all" || "$1" == "a" ]]; then

        echo "Measuring throughput" | tee -a $LOG

        #Copy fio.txt
        source_file="$current_directory"
        txt="fio.txt"

        cp /"$source_file/$txt" /test_bench
        echo "Copy done" | tee -a $LOG

        # Initialization
        if [ -e RND* ]; then
            sudo rm RND*
            sudo rm SEQ*
        fi

        date
        #sudo smartctl -a /dev/nvme0 | grep Temperature | tee -a $LOG
        echo "------------------------------------------------" | tee -a $LOG

        fio -f fio.txt --output-format=terse | awk -F ';' '{ speed = (($7+$48) * 1024) / 1000; unit = "KB/s";
        if (speed >= 1000000) 
            { speed = (speed / 1000000); unit = "GB/s" }
        else if (speed >= 1000) 
            { speed = (speed / 1000); unit = "MB/s" };
        printf "%s %.3f %s\n", $3, speed, unit }' | awk -F '[- ]' '{ if (NR % 2 == 1) printf "%s-%s %s %s ", $1, $2, $4, $5; else print $4, $5 }' | awk 'BEGIN{ print "|   Test Name    |     Read     |    Write     |";
        print "|----------------|--------------|--------------|"}; { printf "| %14s | %7s %s | %7s %s |\n", $1, $2, $3, $4, $5 }' | tee -a $LOG

        sudo rm RND*
        sudo rm SEQ*
        sudo rm "$txt"        
    fi	
#====================Interval======================
    if [[ "$1" == "all" || "$1" == "a" ]]; then

        #Plase define time-span
        time=60
        echo "Wait 60 seconds" | tee -a $LOG
        sleep $time

        #secure_erase
        echo "=========================secure erase==============-============" | tee -a $LOG   

        echo -n "Execute secure erase?[y/n]" | tee -a $LOG   
        read ANS
        case $ANS in
        "" | [Yy]*)
        echo -n "Input device name to secure erase (ex.nvme0n1):" | tee -a $LOG   
        read device 
        sudo nvme format /dev/$device | tee -a $LOG   
        echo "Complete!" | tee -a $LOG   
        ;;
        *)
        echo "Canceled" | tee -a $LOG   
        ;;
        esac
    fi
#====================Latency======================  
    if [[ "$1" == "latency" || "$1" == "l" || "$1" == "all" || "$1" == "a" ]]; then	

        echo "★Measuring latency" | tee -a $LOG

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
   
        echo "===================RANDQ32T16(read)=======================" 
        fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randread --name RANDQ32T16_read --direct 1 --numjobs 16 --iodepth 32 --gtod_reduce 0 --runtime 60 --stonewall 

        echo "===================RANDQ32T16(write)=======================" 
        fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randwrite --name RANDQ32T16_write --direct 1 --numjobs 16 --iodepth 32 --gtod_reduce 0 --runtime 60 --stonewall 

        echo "===================RANDQ1T1(read)=======================" 
        fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randread --name RANDQ1T1_read --direct 1 --numjobs 1 --iodepth 1 --gtod_reduce 0 --runtime 60 --stonewall 

        echo "===================RANDQ1T1(write)=======================" 
        fio --loops 25 --bs 4k --size 1Gi --ioengine libaio  --rw randwrite --name RANDQ1T1_write --direct 1 --numjobs 1 --iodepth 1 --gtod_reduce 0 --runtime 60 --stonewall 

        ) | tee -a $LOG        
    fi  
    
    sudo rm RND*
    sudo rm SEQ*
    
echo "PCIe test completed!" | tee -a $LOG

#back to initial directory
cd "$current_directory"

echo "////Finish////" | tee -a $LOG

