#!/bin/bash

# filename: vm-on.sh
# path: ~/scripts/vm-on
# box: VirtualBox -> ShinyWebApp (Ubuntu Server)
# purpose: start VirtualBox VM in headless mode and connect via ssh
# version: 01/09/2014
# notes: expect parameter: vm-on vmName; chmod a+x ~/.scripts/vm-on
# notes: trying connecting every 3 seconds for 2 mins
# notes: after first fail, script sleeps for 3 seconds and $t will increment by 1
# notes: continues for 24 times (24 * 3s = 72s). 

clear

# variable to store initial parameter
VMNAME=$1

# variable to store current run status of vm
VMSTATUS=`VBoxManage list runningvms | grep $VMNAME | wc -l`

# variable to store vm's internal network ip address

if [ $VMSTATUS = 1 ]; then
	echo "uh, $USER, $VMNAME is already up! Let's connect..."
	ssh $VMNAME
else
	echo "starting $VMNAME now..."
	VBoxManage startvm $VMNAME -type headless >/dev/null 2>&1
	if [ `VBoxManage list runningvms | grep $VMNAME | wc -l` = "1" ]; then
		echo "$VMNAME is up, now waiting for OpenSSH..."
#		VMIP=`VBoxManage guestproperty get $VMNAME "/VirtualBox/GuestInfo/Net/1/V4/IP" | cut -c 8-`
		echo $VMIP
		sleep 10
#		t=1
#		while [ $t -le 24 ]; do
#		  echo "checking status of SSH service..."
#			ping -c1 $VMIP		  
#			output=`nc $VMIP 22 -v -n -w 2 |grep -ow "SSH"`
#		  if [ "$output" == "SSH" ]; then
#		    echo "SSH is now enabled!"
#		    ssh $VMNAME
#		    break
#		  else
#		    sleep 3
#		    (( t++ ))
#		    echo "trying again..."
#		  fi
#		done
	else 
		echo "Darn it, $VMNAME doesn't want to start. Check name against vm list:"
		VBoxManage list vms
	fi
fi
