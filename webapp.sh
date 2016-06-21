#!/usr/bin/env bash

############################################################
##  filename: webapp.sh                                   ##
##  path:     ~/src/config/bin                            ##
##  purpose:  automate angular app scaffolding; run http  ##
##  date:     06/21/2016                                  ##
##  repo:     https://github.com/WebAppNut/bin            ##
##  run:      $ webapp.sh                                 ##
##  alias:    $ alias napp='webapp.sh'                    ##
############################################################

# notes:
# pass in single string arguments for app name and port, e.g. $ napp myApp 1337
# default app name is wip, if wip exists, timestamp appended to app name
# default port number without argument is 8080, if exists, generates random number
# add npm packages to install to the node_apps array
# change path to your app directory with app variable
# dir structure (bower_components only has level 1 listed):
# ├── app
# │   ├── app.js
# │   ├── controller.js
# │   ├── factory.js
# │   └── partials
# │       └── home.html
# ├── bower.json
# ├── bower_components
# │   ├── angular
# │   ├── angular-ui-router
# │   ├── bootstrap
# │   ├── jquery
# │   └── roboto-fontface
# ├── index.html
# ├── package.json
# ├── scripts
# └── styles
#     └── main.css

# boilerplate for index.html
app_view() {
# feed commands via heredoc; don't indent functon code-block
cat <<- EOF > $app_dir/$app_name/index.html
<!DOCTYPE html>
<html ng-app="$app_name">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <title>$app_name</title>
  <!-- 3rd party css -->
  <link rel="stylesheet" href="bower_components/roboto-fontface/css/roboto/roboto-fontface.css">
  <link rel="stylesheet" href="bower_components/bootstrap/dist/css/bootstrap.css">
  <!-- app css -->
  <link rel="shortcut icon" href="">
  <link rel="stylesheet" href="styles/main.css">
</head>
<body>
  <div class="myClass">
    <h3>My New App: $app_name</h3>
    <h4>HTML Status: up!</h4>
    <h4>CSS Status: <span class="status">up!</span></h4>
    <h4>Boostrap Status:
      <button type="button" class="btn btn-primary btn-sm">
        <i class="glyphicon glyphicon-ok add"></i>
      </button></h4>

    <!-- load partials -->
    <ui-view></ui-view>
  </div>

  <!-- 3rd party scripts -->
  <script src="bower_components/jquery/dist/jquery.js"></script>
  <script src="bower_components/bootstrap/dist/js/bootstrap.js"></script>
  <script src="bower_components/angular/angular.js"></script>
  <script src="bower_components/angular-ui-router/release/angular-ui-router.js"></script>
  <!-- app scripts -->
  <script src="app/app.js"></script>
  <script src="app/controller.js"></script>
  <script src="app/factory.js"></script>
</body>
</html>
EOF
} # function end: app_view

# boilerplate for home.html partial
app_part() {
cat <<- EOF > $app_dir/$app_name/app/partials/home.html
<h4>Angular (module/controller/ui-router) Status: {{myCtrl.status}}</h4>
<h4>HTTP Port: {{myCtrl.port}}</h4>
EOF
} # function end: app_part

# boilerplate for main.css
app_css() {
cat <<- EOF > $app_dir/$app_name/styles/main.css
body {
  font-family: 'Roboto', sans-serif;
  padding: 10px;
}
.status {
  color: white;
  background-color: green;
}
EOF
} # function end: app_css

# boilerplate for app.js
app_mod() {
cat <<- EOF > $app_dir/$app_name/app/app.js
// IIFE (immediately-invoked function expression)
(function() {

  // create new angular module (setter); inject dependencies
  angular.module('$app_name', [
    'ui.router'
  ])
    .run(runRouter)
    .config(configRouter);

  // minification-safety
  runRouter.\$inject = ['\$state', '\$rootScope'];

  // function declaration with injected dependencies
  function runRouter(\$state, \$rootScope) {
    \$rootScope.\$state = \$state;
  }

  configRouter.\$inject = ['\$stateProvider', '\$urlRouterProvider'];

  // inject factory dependency
  function configRouter(\$stateProvider, \$urlRouterProvider, myFactory){
    \$stateProvider
      .state('home',{
        url:           '/',
        templateUrl:   'app/partials/home.html',
        controller:   'myController as myCtrl'
      });

    \$urlRouterProvider.otherwise('/');
  } // function end: configRouter

})(); // function end: IIFE
EOF
} # function end: app_mod

# boilerplate for controller.js
app_ctrl() {
cat <<- EOF > $app_dir/$app_name/app/controller.js
(function() {

  // reference existing angular module (getter)
  angular.module('$app_name')
    .controller('myController', myController);

  function myController() {
    var myCtrl = this;
    myCtrl.status = 'up!';
    myCtrl.port = location.port;
    console.log('myController: ', myCtrl.status);
  }

})(); // function end: IIFE
EOF
} # function end: app_ctrl

# boilerplate for factory.js
app_ftry() {
cat <<- EOF > $app_dir/$app_name/app/factory.js
(function() {

  angular.module('$app_name')
    .factory('myFactory', [myFactory]);

  function myFactory(){
    var myFtry = this;
  }

})(); // function end: IIFE
EOF
} # function end: app_ftry

get_depends() {
  # switch to app directory
  cd $app_dir/$app_name

  # bower install client-side libraries/module
  # run bower.json setup; enter to accept default values
  bower init

  # bower packages to install
  # see global installs @https://github.com/WebAppNut/provision/osx_app.sh
  bower_apps=(
    angular           # https://github.com/angular/bower-angular
    angular-ui-router # https://github.com/angular-ui/ui-router
    bootstrap         # http://getbootstrap.com/getting-started
    roboto-fontface   # https://github.com/choffmeister/roboto-fontface-bower
  )

  # loop through node package install; write as package.json dependencies
  for i in "${bower_apps[@]}"; do
    echo -e "$green\n \bbower install $i... $rs"
    bower install $i --save
  done

  # install server-side modules
  # run package.json setup; enter to accept default values
  npm init

  # node packages to install
  # see global installs @https://github.com/WebAppNut/provision/osx_app.sh
  node_apps=(
  )

  # loop through node package install; write as package.json dependencies
  for i in "${node_apps[@]}"; do
    echo -e "$green\n \bnode install $i... $rs\n"
    node install $i --save
  done
}

init_repo(){
  # create new git repo
  echo -e "$green\n \bcreate new git repo... $rs\n"
  git init

  # stage all files
  echo -e "$green\n \bstaging all repo files... $rs"
  git add -A

  # commit staged files
  echo -e "$green\n \binitial commit of staged files to repo... $rs\n"
  git commit -m 'initial commit'
}

start_http() {
  # check for port argument; run via sudo
  if [ ! -z $2 ]; then
    # assign value of port number argument
    port=$2
  else
    port=8080
    # use default port 8080, but check if already in use
    if lsof -Pi :$port -sTCP:LISTEN &>/dev/null; then
      echo -e "$yellow\n \bport $port is in use! $rs"
      echo -e "$green\n \bgenerating an unused random port number... $rs"

      # generate random port number between 1024 & 9999
      port=$(jot -r 1 1024 9999)

      # while ! lsof -Pi :$port -sTCP:LISTEN &>/dev/null; do
        # port=$(jot -r 1 1024 9999 | uniq -c | awk '{printf $2}')
        # break if new port number if not being used, otherwise regenerate
        # if ! lsof -Pi :$port -sTCP:LISTEN &>/dev/null; then
          # break
        # fi
      # done
      # port=$(jot -r 1 1024 9999 | uniq -c | awk '{printf $2}')
      echo -e "$yellow\n \bwill use port: $port $rs\n"
      set_sudo=true
    fi
  fi

  if [ $set_sudo == "true" ]; then
    # validate sudo user timestamp; otherwise starting http-server in background
    # will not process password prompt; sudo only needed because using -p option
    sudo -v

    # start http server in background so following commands can run in parallel
    sudo http-server -p $port &
  else
    http-server &
  fi

  # terminate process gracefully, otherwise use force
  # pid=$(lsof -i :$port -t); kill -TERM $pid || kill -KILL $pid

  # kill any other http-servers that may be running... not using http-server -p
  # killall node

  # wait until web server port is listening before continuing
  # while ! lsof -Pi :$port -sTCP:LISTEN; do
  #   printf .
  # done
}

go_hack() {
  # open new atom window with project set to $app_name directory
  # end heredoc with prefixed tab: "  ", else unexpected end of file error
  atom $app_dir/$app_name

  # manually open new app instead of http-server -o, for non-default browser
  open -a "Google Chrome.app" "http://localhost:$port"

  # refresh browser & open dev tools console; feed commands via heredoc
  osascript <<- "REFRESH"
    tell application "System Events"
      tell application "Google Chrome" to activate
      keystroke "r" using {command down}
      keystroke "j" using {command down, option down}
    end tell
	REFRESH
}

# unset any residual app_name & app_dir values
unset app_name app_dir

# path to app directory
# app="$HOME/src/training/ru/apps"
app_dir="$HOME/src/apps"

# check for argument
if [ ! -z $1 ]; then
  # check for existing directory; skip if not found
  if [ ! -d $app_dir/$1 ]; then
    app_name=$1
  else
    echo -e "$yellow\n \bApp Already Exists: $1! $rs"
  fi
else
  app_name=wip
  # check for existing wip app; append timestamp to name if found
  if [ -d $app_dir/$app_name ]; then
    # grab current time
    now="$(date +_%Y.%m.%d_%H.%M.%S)"
    # append timestamp to app name
    app_name=wip$now
  fi
fi

# check for existing directory; skip if not found
if [ ! -d $app_dir/$app_name ]; then
  # make new app directory structure
  mkdir -p $app_dir/$app_name/{app/partials,styles,scripts}

  app_view    # function to generate boilerplate index.html
  app_part    # function to generate boilerplate home.html
  app_css     # function to generate boilerplate main.css
  app_mod     # function to generate boilerplate app.js
  app_ctrl    # function to generate boilerplate controller.js
  app_ftry    # function to generate boilerplate factory.js
  get_depends # function to check for bower/node package installs
  init_repo   # function to create git repo; stage files; initial commit
  start_http  # function to start web server on unique port number
  go_hack     # function to open app directory in Atom & open app in Chrome
  sudo -k     # invaldate sudo user's timestamp
fi
