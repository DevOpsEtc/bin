#!/bin/bash

  ###############################################
  ##  filename: tmux_workspaces.sh             ##
  ##  path:     ~/.bin/                        ##
  ##  purpose:  tmux session layout            ##
  ##  date:     12/10/2015                     ##
  ##  repo:     https://github.com/WebAppFlow  ##
  ###############################################

# vim: set fdm=marker:                      # treat triple braces as folds

sess="WebAppFlow ○°⸰"                       # tmux session name
create_sess() {
  # purpose: create new tmux session with multiple windows & default commands
  cd                                        # ensure at $HOME
  # create new detached session; name it; name default window
  tmux new-session -d -s "$sess" -n 'wip'

  # new-window: -t [sess_name]:[window_num] [window_name]
  tmux neww -t "$sess":2 -n 'irc'           # new irc window
  tmux neww -t "$sess":3 -n 'logs'          # new logs window
  tmux neww -t "$sess":4 -n 'perf'          # new notes window

  # split-window: -t [sess_name]:[window_num].[pane_num] [direction] [%]
  # tmux splitw -t "$sess":1.1 -h -p 28       # horizontal: 72% left; 28% right
  # tmux splitw -t "$sess":1.2 -v             # vertical: 50% top; 50% bottom
  tmux splitw -t "$sess":1.1 -v -p 20       # vertical: 72% top; 20% bottom
  tmux splitw -t "$sess":2.1 -h -p 34       # horizontal: 34% left; 66% right
  tmux splitw -t "$sess":2.1 -h             # horizontal: 50% left; 50% right
  tmux splitw -t "$sess":3.1 -h             # horizontal: 50% left; 50% right
  tmux splitw -t "$sess":3.1 -v             # vertical: 50% top; 50% bottom
  tmux splitw -t "$sess":3.2 -v             # vertical: 50% top; 50% bottom
  tmux splitw -t "$sess":4.1 -v -p 20       # vertical: 72% top; 20% bottom

  # wait till shell fully loaded
  sleep 4

  # send same command to all panes in all windows
  # send-keys: -t [sess_name]:[window_num].[pane_num] [command] [^m]
  # for i in {1..4}; do
    # tmux setw -t "$sess":$i synchronize-panes
    # tmux send -t "$sess":$i.1 'clear' C-m
    # tmux setw -t "$sess":$i synchronize-panes
  # done
  tmux send -t "$sess":1.1 'vim' C-m
  # tmux send -t "$sess":1.2 'gitc status' C-m
  # tmux send -t "$sess":1.3 'gitc log' C-m
  # tmux send -t "$sess":2.1 'vim -c "SLoad Notes"' C-m
  # tmux send -t "$sess":3.1 'irssi'
  # tmux send -t "$sess":4.2 'tail -F'

  tmux selectw -t "$sess":1                 # set focus to 1st window
  tmux selectp -t 1                         # set focus to 1st pane
  tmux attach -t "$sess"                    # attach to new session
}
attach_sess() {
  # purpose: attach to existing session if exists, otherwise create
  # tmux attach -t "$sess" || create_sess
  if tmux has-session -t "$sess" 2> /dev/null; then
    echo -e "\n$green \battaching to tmux session: "$sess"...\n"
    sleep 1
    # attach to existing session
    tmux attach -t "$sess"
  else
    echo -e "\n$green \bcreating new tmux session: "$sess"...\n"
    # call function to create new session
    create_sess
  fi
}

# do if not already inside tmux
[ ! -z $TMUX ] && echo -e "\n$yellow \btmux already running; force nesting: \n\$ unset \$TMUX && w1" || attach_sess
