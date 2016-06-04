#!/bin/bash

# filename: vbGuestAdd.sh
# purpose: update guest tools inside of base image
# version: 01/14/2014

# download the guest additions ISO file
wget http://download.virtualbox.org/virtualbox/4.3.6/VBoxGuestAdditions_4.3.6.iso

# mount the ISO, run the installer/updater
sudo mkdir /media/stuff
sudo mount -o loop -t iso9660 VBoxGuestAdditions_4.3.6.iso /media/stuff
sudo sh /media/stuff/VBoxLinuxAdditions.run

# unmount and delete cruft 
sudo umount /media/stuff
sudo rm -r /media/stuff
rm VBoxGuestAdditions_4.3.6.iso
