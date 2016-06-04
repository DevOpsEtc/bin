#!/bin/bash

# vim:fdm=marker

############################################
#### filename: pdf.sh   	 							####
#### version: 01/10/2015	  						####
#### purpose: convert txt files to pdf	####
############################################

# variables
pathIn=$HOME/Dev
pathOut=$HOME/Desktop/PrintMe
fileCount=0

folders=$( find -L dev -type d | egrep -v "^dev/(archive|boxes|mindmaps|projects|settings|vbox)" | sed 's,^[^/]*/,,' )
files=$( find -L dev -type f | egrep -v "^dev/(archive|boxes|mindmaps|projects|settings|vbox)|.DS_Store|.swp|.swo|.bak" | sed 's,^[^/]*/,,' )

main() {
	# loop through array of filenames
  for folder in ${folders[@]}; do
    if [ ! -d $pathOut/${folder} ]; then
      mkdir -p $pathOut/${folder}
    fi;
  done;
  for file in ${files[@]}; do
    echo -e "$gold""\nCreating ${file}.rtf...$nc"
    textutil -convert rtf -font 'Courier New' -fontsize 19 ${pathIn}/${file} -output $pathOut/${file}.rtf
    echo -e "$gold""\nCreating ${file}.pdf...$nc"
    cupsfilter -D $pathOut/${file}.rtf > $pathOut/${file}.pdf
    let fileCount=$fileCount+1
  done;
  echo -e "$lime""\n${fileCount} PDFs ready to print!$nc"
  exit 0
}

main "$@"
