#!/bin/bash

title="Available Vim Sessions:"
prompt="Which session # to load?"
options=( $(gfind .vim/sessions -type f -printf '%P\n' | grep -v ".DS_Store") )

clear
echo -e "\n$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do
  case "$REPLY" in
    1 ) vim -S ~/.vim/sessions/$opt;;
    $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break; exit;;
    *) echo -e "\n$REPLY...WTF!?\n";continue;;
  esac
  break
done

