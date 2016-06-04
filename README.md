# My Bin (bash script files)

**Notes:**

1. change bin path to desired location:

    `bin_dir=~/src/config/bin`

2. clone bin repo:

    `git clone https://github.com/WebAppNut/bin $bin_dir`

3. append bin directory to existing $PATH statement:

    `export PATH="$bin_dir:$PATH"`

4. run script by typing filename from any path:

    `$ term_colors.sh`

**Optional:**

-   remove repo directory:

    `rm -rf $bin_dir/.git`

-   make permanent by adding to end of existing .bash_profile:

    `echo "export PATH="$bin_dir:$PATH"" >> .bash_profile`

-   create bash alias:

    `echo "alias color='$bin_dir/term_colors.sh'" >> .bash_profile`

**Roadmap:**

-   Refactor key_backup.sh
    -   Switch conditionals to case statements where appropriate
    -   Simplify conditionals
    -   add versioning function to rsync backup
    -   add restore function

**Feel free to fork, but YMMV!**
