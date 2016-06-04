#!/usr/bin/env bash

############################################################
##  filename: webapp.sh                                   ##
##  path:     ~/src/config/bin                            ##
##  purpose:  automate angular app scaffolding; run http  ##
##  date:     06/04/2016                                  ##
##  repo:     https://github.com/WebAppNut/bin            ##
##  run:      $ webapp.sh                                 ##
##  alias:    $ alias napp='webapp.sh'                    ##
############################################################

# notes:
# accepts single string name agrument, e.g. $ napp myApp
# if running script without name argument, will be named wip
# if wip exists, will have timestamp appended to wip
# add bower packages to install to bower_apps array

# path to app directory
app="$HOME/src/training/ru/apps"

# unset any dir_name value
unset $dir_name

# check for argument
if [ ! -z $1 ]; then
  # check for existing directory; skip if not found
  if [ ! -d $app/$1 ]; then
    dir_name=$1
  else
    echo -e "$yellow\n \bApp Already Exists: $1! $rs"
  fi
else
  dir_name=wip
  # check for existing wip directory; append timestamp to name if found
  if [ -d $app/$dir_name ]; then
    # grab current time
    now="$(date +_%Y.%m.%d_%H.%M.%S)"
    # append timestamp to directory name
    dir_name=wip$now
  fi
fi

# check for existing directory; skip if not found
if [ ! -d $app/$dir_name ]; then
  # make new app directory structure
  mkdir -p $app/$dir_name/{app,styles,scripts}

  # make new files
  touch $app/$dir_name/{index.html,/styles/main.css,/app/app.js}

  # switch to app directory
  cd $app/$dir_name

  # run bower.json setup wizard; enter to accept default values
  bower init

  # bower packages to install
  bower_apps=(
    angularjs                  # https://github.com/angular/bower-angular
    angular-ui-router          # https://github.com/angular-ui/ui-router
  )

  # loop through bower package install
  for i in "${bower_apps[@]}"; do
    echo -e "$green\n \bbower install $i... $rs\n"
    bower install $i
  done

  # create html boilerplate with bower & app script links
  html_ang() {
  echo -e "
  <!DOCTYPE html>
  <html>
    <head>
      <script type="text/javascript"
        src="bower_components/angular/angular.js">
      </script>
      <script type="text/javascript"
        src="bower_components/angular-ui-router/release/angular-ui-router.js">
      </script>
      <script type="text/javascript" src="app/app.js"></script>

      <link rel="stylesheet" href="styles/main.css">
      <meta charset="utf-8">
      <title></title>
    </head>
    <body>
      <h3>$dir_name works!</h3>
    </body>
  </html>"
  }

  # append boilerplate html from html_ang function
  echo -e "$(html_ang)" >> $app/$dir_name/index.html

  # kill any other http-servers that may be running... not using http-server -p
  killall node

  # start http server in background so following commands can run in parallel
  http-server &

  # wait until web server port is listening before loading browser
  while ! lsof -Pi :8080 -sTCP:LISTEN; do
    printf .
  done

  # manually open new app instead of using http-server -o (non-default browser)
  open -a "Google Chrome.app" 'http://localhost:8080'

  # refresh browser; feed commands via heredoc
  osascript <<- "REFRESH"
    tell application "System Events"
    	tell application "Google Chrome" to activate
    	keystroke "r" using {command down}
    end tell
  # end heredoc with tab: "	", else unexpected end of file error
	REFRESH
fi
