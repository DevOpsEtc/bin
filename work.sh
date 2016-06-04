#!/bin/bash

  ####################################
  ## filename: work.sh              ##
  ## path:     ~/work/scripts/      ##
  ## version:  04/09/2015           ##
  ## purpose:  automate bettersnap  ##
  ## author:   gp                   ##
  ####################################

# letters can also use keystroke "k" instead of key code
# full keycode map: ~/work/notes/mac_keycodes.txt
# 0 = 29
# 1 = 18
# 2 = 19
# 3 = 20
# 4 = 21
# 5 = 23
# 6 = 22
# 7 = 26
# 8 = 28
# 9 = 25

osascript <<EOD
  # create array of app names
  set appList to {"Finder", "iTerm", "Notes", "Reminders", "Safari"}
  # loop through app names
  repeat with appName in appList
    tell application appName
    # set app as active
    activate
      tell application "System Events"
        # let app catch up before next commands
        delay 1
        if ((appName as string) is equal to "Finder") then
          tell application "Finder"
            # if Finder app started without window then reopen
            if not (exists Finder window) then reopen
            # change to work folder
            set target of front Finder window to POSIX file "$HOME/Work"
          end tell
            # assign keycode variable
          set keyCode to 20
        else if ((appName as string) is equal to "iTerm") then
          # invoke tmux scripted layout
          keystroke "w1"
          keystroke return
          set keyCode to 19
        else if ((appName as string) is equal to "Notes") then
          set keyCode to 21
        else if ((appName as string) is equal to "Reminders") then
          set keyCode to 23
        else if ((appName as string) is equal to "Safari") then
          set keyCode to 18
        end if
        # simulate keystrokes
        key code keyCode using {command down, option down}
      end tell
    end tell
  end repeat
EOD
# fireup itunes & choose radio station
