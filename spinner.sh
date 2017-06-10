#!/usr/bin/env bash

#############################################################
##  filename: spinner.sh                                   ##
##  path:     ~/src/config/bin                             ##
##  purpose:  stdout/stderr eating pid activity indicator  ##
##  date:     02/17/2017                                   ##
##  repo:     https://github.com/DevOpsEtc/bin             ##
##  source:   $ . ~/src/config/bin/spinner.sh              ##
##  run:      $ spin [command]                             ##
#############################################################

# best for processes where you don't need to see output,
# e.g. storing value of command output to variable
#
## spin function check; source parent script; eat stdout & stderr
# if ! type -t spin &>/dev/null; then
# . spinner.sh
# fi
#
# spin [command]

spin() {
  { "$@" & disown; } > /dev/null 2>&1 # command to bg & eat stdout/stderr
  local pid=$! # grab last process id
  local delay=0.05 # set delay between spin frames
  frame_in=0 # starting spin frame
  frames="◓◑◒◐" # spin cycle frames; line: '/-\|'
  frame_cnt=${#frames} # number of spin frames
  printf "$msg_1 " # print command message +space to screen
  tput civis # hide cursor during spin cycle
  while [ $(ps -eo pid | grep $pid) ]; do # do while process id is alive
    printf '\b%s' "${green}${frames:frame_in++%frame_cnt:1}${rs}" # print to screen
    sleep $delay # delay between each frame print
  done
  tput cnorm # show cursor after spin cycle
  echo # pad stdout single line
}
