#!/bin/bash

# vim:fdm=marker

############################################
#### filename: battery.sh               ####
#### filepath: ~/work/scripts/          ####
#### version:  02/04/2015               ####
#### purpose:  tmux battery status      ####
############################################

# notes {{{
# set as executable: chmod a+x ~/work/scripts/battery.sh
# call from tmux statusline: '#(~/work/scripts/battery.sh)'
# }}}
# variables {{{
pmset1=$(pmset -g ps | awk 'NR==2')
pmset2=$(pmset -g batt | awk 'NR==2 { gsub(";", ""); print $2,$4}')
# }}}
# conditional: icon {{{
if echo $pmset1 | grep -q "charged"; then
  icon=✦
elif echo $pmset1 | grep -q "discharging"; then
  icon=⬇
elif echo $pmset1 | grep -q "charging"; then
  icon=⬆
fi;
# }}}
if echo $pmset2 | grep -q "^[0-9]%"; then
  echo "#[fg=colour160]$icon #[fg=white]$pmset2" | sed -e 's/(no//g' -e 's/attached//g'
else
  echo -e $icon $pmset2 | sed -e 's/(no//g' -e 's/attached//g'
fi;

exit 0
