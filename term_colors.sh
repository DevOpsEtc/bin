
##########################################################
##  filename: term_colors.sh                            ##
##  path:     ~/src/config/bin/                         ##
##  purpose:  display color chart of terminal colors    ##
##  date:     06/04/2016                                ##
##  repo:     https://github.com/WebAppNut/bin          ##
##  run:      $ term_colors.sh                          ##
##########################################################

# display foreground & background colors
for fgbg in 38 48 ; do
  # list colors
  for color in {0..256}; do
    # display the color values
    printf "\e[${fgbg};5;%sm %3s \e[0m" "${color}" "${color}"
    # display 10 colors per line
    if [ $((($color + 1) % 17)) == 0 ] ; then
      # pad new line
      echo
    fi
  done
  echo
done
