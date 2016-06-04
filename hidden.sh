#!/bin/bash

# Filename: hidden.sh
# Location: ~/
# Purpose: toggle hidden file visibility
# Version: 10/29/13

STATUS=`defaults read com.apple.finder AppleShowAllFiles`
if [ $STATUS == TRUE ]; 
then
 defaults write com.apple.finder AppleShowAllFiles FALSE
 echo Greg, hidden files are hidden again!
else
 defaults write com.apple.finder AppleShowAllFiles TRUE
 echo Greg, hidden files can now be seen!
fi
KillAll Finder
