#!/bin/bash

echo "[*] Checking dmesg for container info"
dmesg 2>/dev/null | grep "docker\|lxc"

echo

if [ -x /.dockerenv ]; then
	echo "[*] /.dockerenv found"
fi

ntimes=$(grep docker /proc/$$/cgroup | wc -l)
if [ $ntimes -gt 0 ]; then
	echo "[*] Found occurence of docker in /proc/<pid>/cgroup " $ntimes " times"
fi


ntimes=$(grep kube /proc/$$/cgroup | wc -l)
if [ $ntimes -gt 0 ]; then
	echo -e "[*] Found occurence of kube in /proc/<pid>/cgroup\nHello Cluster :)" $ntimes " times"
fi


ntimes=$(grep docker /proc/$$/cpuset | wc -l)
if [ $ntimes -gt 0 ]; then
	echo "[*] Found occurence of docker in /proc/<pid>/cpuset " $ntimes " times"
fi


ntimes=$(grep kube /proc/$$/cpuset | wc -l)
if [ $ntimes -gt 0 ]; then
	echo -e "[*] Found occurence of kube in /proc/<pid>/cpuset\nHello Cluster :) " $ntimes " times"
fi


ntimes=$(grep docker /proc/$$/mountinfo | wc -l)
if [ $ntimes -gt 0 ]; then
	echo "[*] Found occurence of docker in /proc/<pid>/mountinfo " $ntimes " times"
fi


ntimes=$(grep docker /proc/$$/mounts | wc -l)
if [ $ntimes -gt 0 ]; then
	echo "[*] Found occurence of docker in /proc/<pid>/mounts " $ntimes " times"
fi


if [ $(grep overlay /proc/$$/mountstats | wc -l) -gt 0 ]; then
	if [ $(grep docker /proc/$$/mountstats | wc -l) -eq 0 ]; then
		echo "[*] overlay in /proc/<pid>/mounstats but not docker"
		echo "		if docker would be in there we would be on the host"
	fi
fi


if [ $(grep /etc/resolv.conf /proc/$$/mountstats|wc -l) -gt 0 ]; then
	echo "[*] Found /etc/resolv.conf in /proc/<pid>/mountstats"
fi

if [ $(grep /etc/hostname /proc/$$/mountstats|wc -l) -gt 0 ]; then
	echo "[*] Found /etc/hostname in /proc/<pid>/mountstats"
fi

if [ $(grep /etc/hosts /proc/$$/mountstats|wc -l) -gt 0 ]; then
	echo "[*] Found /etc/hosts in /proc/<pid>/mountstats"
fi


seccomp=$(grep Seccomp /proc/$$/status | awk '{ print $2 }')
if [ $seccomp -eq 0 ]; then
	echo "[*] No Seccomp Profile applied."
elif [ $seccomp -eq 1 ]; then
	echo "[*] Seccomp set to SECCOMP_MODE_STRICT"
elif [ $seccomp -eq 2 ]; then
	echo "[*] Seccomp set to SECCOMP_MODE_FILTER"
fi


# Check for UID remapping
first=$(cat /proc/$$/uid_map | awk '{ print $1 }')
second=$(cat /proc/$$/uid_map | awk '{ print $2 }')
if [ $first == $second ]; then
	echo "[*] Within Host UID Namespace!"
fi

# Check for GID remapping
first=$(cat /proc/$$/gid_map | awk '{ print $1 }')
second=$(cat /proc/$$/gid_map | awk '{ print $2 }')
if [ $first == $second ]; then
	echo "[*] Within Host GID Namespace!"
fi

# TODO: Make checks accurate 
if [ $(ip a 2>/dev/null | grep docker | wc -l ) -gt 0 ] || [ $(ifconfig 2>/dev/null | grep docker | wc -l ) -gt 0 ]; then
	echo "[*] Within Host Network Namspace!"
fi


# full capability set
capsetEff=$(grep CapEff /proc/$$/status |awk '{ print $2 }')
capsetInh=$(grep CapInh /proc/$$/status |awk '{ print $2 }')

if [ "0000003fffffffff" == ${capsetEff} ]; then
	echo -e "[*] All Linux Capabilities available\n\tHere we go..."
else
	echo "[*] Capabilities: "
	grep Cap /proc/$$/status
fi


