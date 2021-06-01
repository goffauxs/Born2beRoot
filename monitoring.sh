#!/bin/bash

MEMTOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEMAVAIL=$(awk '/MemAvail/ {print $2}' /proc/meminfo)
MEMUSED=$((MEMTOTAL - MEMAVAIL))
LVM=$(lsblk | awk '/root/ {print $6}')

wall << End_Of_Message
	#Architecture: `uname -a`
	#CPU physical: `lscpu | awk '/^CPU\(s\)/ {print $2}'`
	#vCPU : `grep -c 'processor' /proc/cpuinfo`
	`echo $MEMUSED $MEMTOTAL | awk '{printf "#Memory Usage: %d/%dMB (%.2f%%)\n", ($1/1024), ($2/1024), ($1/$2)*100}'`
	`df --total | tail -n 1 | awk '{printf "#Disk Usage: %d/%dGb (%d%%)\n", ($3/1024), ($2/1048576), $5}'`
	`awk '{print "#CPU load: "$1"%\n"}' /proc/loadavg`
	#Last boot: `who -b | awk '{print $3" "$4}'`
	#LVM use: `if [ "$LVM" = "lvm" ];
	then
		echo "yes"
	else
		echo "no"
	fi`
	`awk '$4=="01" {count++} END{printf "#Connexions TCP : %d ESTABLISHED\n", count}' /proc/net/tcp`
	#User log: `who | awk '{print $1}' | uniq | wc -l`
	`ip -br a show $(ip route show default | awk '{print $5}') | sed 's/\/[[:digit:]]\{1,3\}//g' | awk '{printf "#Network: IP %s (%s)\n", $3, $4}'`
	`grep -c 'COMMAND' /var/log/sudo/sudo.log | awk '{printf "#Sudo : %d cmd\n", $1}'`
End_Of_Message
