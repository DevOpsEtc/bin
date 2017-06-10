#!/usr/bin/env bash

#######################################################
##  filename: key_backup.sh                          ##
##  path:     ~/src/config/bin/                      ##
##  purpose:  USB key backup (Time Machine & Rsync)  ##
##  date:     06/24/2016                             ##
##  repo:     https://github.com/DevOpsEtc/bin       ##
##  run:      $ key_backup.sh                        ##
##  alias:    $ alias kb='key_backup.sh'             ##
#######################################################

# notes:
# - this script does a standalone Time Machine backup and a rsync backup to an
# encrypted partition on a usb thumb drive
# - mobile-bk paritions are prevented from automount via fstab entries
#     view fstab: $ cat /etc/fstab
# - partitions are mounted and unmounted on the fly
# - flash drive can remain in usb port or removed (no eject needed if unmounted)
#     display active mounts: $ mount
# - permission errors are typically due to duplicate mount points
#     check mount points for dupes:
#       $ ls /Volumes (e.g. waf-bk 1)
#       $ diskutil eject waf-bk
#       $ sudo rm -rf /Volumes/{waf-bk\ 1,wab-bk}; ls /Volumes
# - partitions:
#     backup-rs (rsync backup to waf-bk)
#     waf-bk (encrypted sparsebundle)
#     backup-tm (time machine backup to encrypted sparsebundle)
# - use disk utility to force any stuck mounts/ejects or simply unplug hd
# - list current time machine exclusions:
#   $ defaults read /library/preferences/com.apple.timemachine.plist excludebypath
# - display exclusion list used in last tm backup:
#   $ sudo cat /Volumes/backup-tm/backups.backupdb/waf/latest/.exclusions.plist
# - rsync options:
#   v(verbose) z(file compression) h(human-readable numbers)
#   sparse(sparse efficient) delete(sync source deletions to target) n(dry run)
#   inplace(does not recreate existing file; use only if sparsebundle exists)
#   a(archive: recursive & preserves sym links, file perms, owners & timestamps)
#
# variables
# mount point names
b1=backup-rs
b2=backup-tm
b3=waf-bk
# used in sed regexp in backup function
b2X="\/${b2}"
# to be used when refactor rsync backup to handle multiple versions
# time=$(date +"%y-%m-%d %h:%m:%s")
# last=$time
me=$(whoami)
# mount point paths
b1_pth=/Volumes/$b1
b2_pth=/Volumes/$b2
b3_pth1=/Volumes/$b3
b3_pth2=/Volumes/$b3/$HOSTNAME/backups
# b3_pth2=/Volumes/$b3/$HOSTNAME/backups/$time
one_pass=2bua8c4s2c.com.agilebits.onepassword-osx-helper
msgMnt1="Mounting:"
msgMnt2="Unmounting:"
msgMnt3="Still Mounted:"
msgMntE1="Already mounted:"
msgMntE2="Already unmounted:"
width=$(tput cols)
#
# arrays
partitions=($b1 $b2)

# time machine exclusions
tm_exclude=(
  .DocumentRevisions-v100
  .Spotlight-v100
  .Trashes
  .vol
  .dbfseventsd
  .fseventsd
  Applications
  bin
  cores
  etc
  Library
  Network
  opt
  private
  "Previous System"
  sbin
  System
  tmp
  Users/master
  Users/Guest
  Users/shared
  Users/$me/.composer
  Users/$me/.cups
  Users/$me/.dropbox
  Users/$me/.subversion
  Users/$me/Applications
  "Users/$me/Back Burner"
  Users/$me/Desktop
  Users/$me/Documents
  Users/$me/Downloads
  Users/$me/Dropbox
  Users/$me/eReading
  "Users/$me/Family Tree"
  Users/$me/Library/Accounts
  "Users/$me/Library/Application Scripts"
  "Users/$me/Library/Application Support/Google"
  "Users/$me/Library/Application Support/Dropbox"
  Users/$me/Library/Assistants
  Users/$me/Library/Audio
  "Users/$me/Library/Autosave Information"
  Users/$me/Library/Caches
  Users/$me/Library/Colorpickers
  Users/$me/Library/Colors
  Users/$me/Library/Com.apple.nsurlsessiond
  Users/$me/Library/Compositions
  Users/$me/Library/Cookies
  Users/$me/Library/Favorites
  Users/$me/Library/Fontcollections
  Users/$me/Library/Gamekit
  Users/$me/Library/Google
  Users/$me/Library/Identityservices
  Users/$me/Library/Imovie
  "Users/$me/Library/Input Methods"
  "Users/$me/Library/Internet Plug-Ins"
  Users/$me/Library/iTunes
  "Users/$me/Library/Keyboard Layouts"
  Users/$me/Library/Keychains
  Users/$me/Library/Languagemodeling
  Users/$me/Library/Launchagents
  Users/$me/Library/Preferencepanes
  Users/$me/Library/Printers
  Users/$me/Library/Pubsub
  Users/$me/Library/Quicklook
  "Users/$me/Library/Screen Savers"
  Users/$me/Library/Services
  Users/$me/Library/Sounds
  Users/$me/Library/Virtualbox
  Users/$me/Library/Voices
  Users/$me/Library/Webkit
  Users/$me/Manuals
  Users/$me/Movies
  Users/$me/Music
  Users/$me/Pictures
  Users/$me/Trash
  "Users/$me/VirtualBox VMs"
  "Users/$me/Work Archive"
  usr
  var
  Volumes
  www
)

#
main() {
  clear
  # greet
  menu
  # redisplay menu until quit
  while true; do menu; done
  exit 0
}
menu() {
  title="Flash HD Backup Tasks:"
  prompt="Choose option: "
  options=("Mount HDs" "Backup-RS" "Backup-TM" "Unmount HDs")
  echo -e "$green \n$title\n $rs"
  PS3=$(echo -e "$green \n$prompt $rs")
  select opt in "${options[@]}" "Quit"; do
    msgMenu="$blue \n$REPLY ➙ $opt $rs"
    case "$REPLY" in
      1) echo -e $msgMenu; bk=0; mounter;;
      2) echo -e $msgMenu; bk=1; mounter; backup; unmounter;;
      3) echo -e $msgMenu; bk=2; mounter; backup; unmounter;;
      4) echo -e $msgMenu; bk=0; unmounter;;

      $(( ${#options[@]}+1 )) ) echo -e "$blue \nQuit! $rs"; exit;;
      *) echo -e "$red \n$REPLY ➙ WTF!? $rs"; continue;;
    esac
    break
  done;
}
mounter() {
  attach() {
    # only do if the waf-bk sparsebundle is NOT attached
    if ! mount | grep -q $b3; then
      echo -e "$green \nDecrypting, attaching & mounting: $b3...$rs"
      # attach encrypted sparsebundle
      hdiutil attach /Volumes/$b1/$b3.sparsebundle || { exit 1; }
    else
      # display error if detached
      echo -e "$red \n$msgMntE1 $b3 $rs"
    fi;
  }
  # if "Mount HDs" chosen from menu
  if [ "$bk" == "0" ] ; then
    # loop through array of partition names
    for part in "${partitions[@]}"; do
      # only do if partition is NOT mounted
      if ! mount | grep -q ${part}; then
        # display partition name being mounted
        echo -e "$green \n$msgMnt1 ${part} $rs"
        # mount partition
        diskutil mount ${part} || { exit 1; }
      else
        # display error if mounted
        echo -e "$red \n$msgMntE1 ${part} $rs"
      fi;
    done;
    # call attach function
    attach
  # if "Backup-RS" chosen from menu
  elif [ "$bk" == "1" ] ; then
    # only do if the backup-rs partition is NOT mounted
    if ! mount | grep -q $b1; then
      # display partition name being mounted
      echo -e "$green \n$msgMnt1 $b1 $rs"
      # mount partition
      diskutil mount $b1 || { exit 1; }
      # call attach function
      attach
    else
        # display error if mounted
      echo -e "$red \n$msgMntE1 $b1 $rs"
    fi;
  # if "Backup-TM" chosen from menu
  elif [ "$bk" == "2" ] ; then
    # only do if the backup-tm partition is NOT mounted
    if ! mount | grep -q $b2; then
      # display partition name being mounted
      echo -e "$green \n$msgMnt1 $b2 $rs"
      # mount partition
      diskutil mount $b2 || { exit 1; }
    else
      # display error if mounted
      echo -e "$red \n$msgMntE1 $b2 $rs"
    fi;
  fi;
}
backup() {
	# rsync inclusions
	rs_include=(
		Archive
	  Desktop
		Library/Containers/$one_pass/Data/Library/Backups
		"Library/Mobile Documents"
		src
	  wip
	  work
	)

	# rsync backup exclusions
	rs_exclude=(
		'node_modules'
    'bower_modules'
    'vendor'
    '$RECYCLE.BIN'
    '$Recycle.Bin'
    '.AppleDB'
    '.AppleDesktop'
    '.AppleDouble'
    '.com.apple.timemachine.supported'
    '.dbfseventsd'
    '.DocumentRevisions-V100*'
    '.DS_Store'
    '.fseventsd'
    '.PKInstallSandboxManager'
    '.Spotlight*'
    '.SymAV*'
    '.symSchedScanLockxz'
    '.TemporaryItems'
    '.Trash*'
    '.vol'
    '.VolumeIcon.icns'
    'Desktop DB'
    'Desktop DF'
    'hiberfil.sys'
    'lost+found'
    'Network Trash Folder'
    'pagefile.sys'
    'Recycled'
    'RECYCLER'
    'System Volume Information'
    'Temporary Items'
    'Thumbs.db'
	)
	# assign value of exclude switch loop
	rs_exd_cmd="${rs_exclude[@]/#/--exclude=}"
	# rsync command for regular backup
	snc1="rsync -vzha --delete --delete-excluded $rs_exd_cmd"
	# rsync command for archive sparsebundle backup
	snc2="rsync -vzha --sparse --delete --delete-excluded $rs_exd_cmd"
	# rsync command for  backup
	snc3="rsync -vzha --inplace --delete --delete-excluded $rs_exd_cmd"

	# if "Backup-RS" chosen from menu
  if [ $bk == "1" ] ; then
    if mount | grep -q $b1; then
      # directory check; create if missing
      if [ ! -d "$b3_pth2" ]; then
        echo -e "$green \nCreating directory structure on $b3...$rs"
        for d in "${rs_include[@]}"; do
          mkdir -p "/Volumes/waf-bk/waf/backups/${d}"
        done;
        rm -rf $b3_pth2/Library
      fi;
      # run rsync backup
      echo -e "$green \nStarting rsync backup to $b3...$rs"
      for j in "${rs_include[@]}"; do
        echo -e "$green \nBacking up "$j"...$rs"
        if [ "$j" == Archive ]; then
          $snc2 ~/"$j" $b3_pth2
        elif [[ ~/"$j" == *$one_pass* ]]; then
          $snc1 ~/"$j" $b3_pth2/1Password
        else
          $snc1 ~/"$j" $b3_pth2
        fi;
      done;
    else
      echo -e "$red \n$msgMntE1 $b1 $rs"
      exit 1;
    fi;
  # if "Backup-TM" chosen from menu
  elif [ $bk == "2" ] ; then
    # only do if backup-tm is already mounted
    if mount | grep -q $b2; then
      echo -e ""
      # ask for sudo password upfront
      sudo -v
      # sudo time stamp keep alive; resets when backup complete
      while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
      # disable time machine daemon
      echo -e "$green \n1/7 Disabling Time Machine...$rs"
      sudo tmutil disable
      # set time machine backup destination
      echo -e "$green \n2/7 Adding mount as Time Machine destination...$rs"
      sudo tmutil setdestination -a $b2_pth
      # grab tm backup id; created @setdestination; killed @removedestination
      # sed: print line after regexp; kill characters from line start to ": "
      uuid=$(tmutil destinationinfo | sed -n "/$b2X/{n;s/^.*: //p;}")
      # overide regular backup exclusions
      echo -e "$green \n3/7 Adding Time Machine exclusions...$rs"
      # loop through array of file names; populate exclusion list
      for t in "${tm_exclude[@]}"; do
        # uncomment following to see files names being added
        # echo "/${t}"
        sudo tmutil addexclusion -p "/${t}" || { exit 1; }
      done;
      # start time machine backup
      echo -e "$green \n4/7 Starting Time Machine...$rs"
      tmutil startbackup --block --destination $uuid || { exit 1; }
      # restore regular backup exclusions
      echo -e "$green \n5/7 Removing Time Machine exclusions...$rs"
      for t in "${tm_exclude[@]}"; do
        # uncomment following to see files names being removed
        # echo "/${t}"
        sudo tmutil removeexclusion -p "/${t}" || { exit 1; }
      done;
      # remove mount as time machine destination
      echo -e "$green \n6/7 Removing mount as Time Machine destination...$rs"
      sudo tmutil removedestination $uuid
      echo -e "$green \n7/7 Enabling Time Machine...$rs"
      # enable time machine daemon
      sudo tmutil enable
    else
      echo -e "$red \n$msgMntE1 $b2 $rs"
      exit 1;
    fi;
    # invalidate sudo time stamp; require password next time sudo run
    sudo -k
  fi;
}
unmounter() {
  detach() {
    # only do if the waf-bk sparsebundle is attached
    if mount | grep -q $b3; then
      # detach spasebundle
      echo -e "$green \nUnmounting, detaching & encrypting: $b3...$rs"
      hdiutil detach $b3_pth1 || { exit 1; }
      # reclaim free space
      echo -e "$green \nCompacting $b3...$rs"
      hdiutil compact /Volumes/$b1/$b3.sparsebundle -batteryallowed || { exit 1; }
    else
      # display error if already detached
      echo -e "$red \n$msgMntE2 $b3 $rs"
    fi;
  }
  notifier() {
    # if either partition is mounted, then do nothing
    if mount | grep -q $b1 ; then
      echo -e "$red \n$msgMnt3 $b1 $rs"
    elif mount | grep -q $b2 ; then
      echo -e "$red \n$msgMnt3 $b2 $rs"
    else
      echo -e "$blue \nPartitions unmounted. Safe to remove mobile-bk!$rs"
      # throw notification
      terminal-notifier -title '✅ mobile-bk:' -message 'Flash HD can now be removed!' -sound 'Blow'
    fi;
  }
  # if "Unmount HDs" chosen from menu
  if [ "$bk" == "0" ] ; then
    # call detach function
    detach
    # loop through array of partition names
    for part in "${partitions[@]}"; do
      # only do if partition is mounted
      if mount | grep -q ${part}; then
        # display partition name being unmounted
        echo -e "$green \n$msgMnt2 ${part} $rs"
        # unmount partition
        diskutil unmount ${part} || { exit 1; }
      else
        # display error if not mounted
        echo -e "$red \n$msgMntE2 ${part} $rs"
      fi;
    done;
  # if "Backup-RS" chosen from menu
  elif [ "$bk" == "1" ] ; then
    # call attach function
    detach
    # only do if the backup-rs partition is mounted
    if mount | grep -q $b1; then
      # display partition name being unmounted
      echo -e "$green \n$msgMnt2 $b1 $rs"
      # unmount partition
      diskutil unmount $b1 || { exit 1; }
    else
      # display error if not mounted
      echo -e "$red \n$msgMntE2 $b1 $rs"
    fi;
  # if "Backup-TM" chosen from menu
  elif [ "$bk" == "2" ] ; then
    # only do if the backup-tm partition is mounted
    if mount | grep -q $b2; then
      # display partition name being unmounted
      echo -e "$green \n$msgMnt2 $b2 $rs"
      # unmount partition
      diskutil unmount $b2 || { exit 1; }
    else
      # display error if not mounted
      echo -e "$red \n$msgMntE2 $b2 $rs"
    fi;
  fi;
  notifier
}

main "$@"
