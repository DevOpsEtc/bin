#!/usr/bin/env bash

################################################################
##  filename: ru.sh                                           ##
##  path:     ~/src/config/bin/                               ##
##  purpose:  ru scaffolding; clone repos; pull repo updates  ##
##  date:     06/04/2016                                      ##
##  repo:     https://github.com/WebAppNut/bin                ##
##  run:      $ ru.sh                                         ##
##  alias:    $ alias rgpl='ru.sh'                            ##
################################################################

# path to base directory
base="$HOME/src/training/ru"

# check if ru directory already exists; skip if yes, otherwise create
if [ ! -d $base ]; then
  # create directory structure with 10 weekly folders under repo/exercises/
  for i in {1..10}; do
    echo -e "$yellow \bWeek $i ✓ $rs"
    # make directory structure
    mkdir -p $base/{apps,misc,repo/{exercises/wk-$i,projects/{midterm,demo}},_private/ru_repos}
  done
fi

# path to cloned repos
repo="$base/_private/ru_repos/"

# list of ru repos to git clone & git pull
repos=(
  May2016DemoCode
  exercise-starters
  exercise-solutions
)

# loop through repos array; initial clone if not exist, otherwise git pull
for i in "${repos[@]}"; do
  # check for repo & install if not found
  if [ ! -d $repo/$i ]; then
    # clone repo
    echo -e "$yellow \bcloning repo: $i $rs"
    git clone https://github.com/RefactorU/$i $repo/$i
  else
    echo -e "$yellow \bchecking for any repo changes: $i $rs"
    orig_pwd="$(pwd)" # store present working directory
    cd $repo/$i       # change directory to cloned repo
    git pull          # grab any repo updates if already exists
    cd $orig_pwd      # goto original directory
  fi
done
