#!/usr/bin/env bash

#########################################################
##  filename: key_pair.sh						   					       ##
##  path:     ~/src/config/bin/         				       ##
##  purpose:  Generate Public-Key Encryption Key Pair  ##
##  date:     06/10/2017								               ##
##  repo:     https://github.com/DevOpsEtc/bin	       ##
##  execute:  $ ~/src/config/bin/key_pair.sh           ##
#########################################################

# remove entry from authorized_keys
# sed -i '/<key_name>/d' ~/.ssh/authorized_keys

# recreate public key from private key
# ssh-keygen -y

# remove all SSH Agent entries
# ssh-add -D to remove all
# ssh-add -L to view entries

key_path=~/src/config/keys  # new keypair path

read -rp $'\n'"$yellow""Enter key name: " ssh_key_name

read -rsp $'\n'"$yellow""Enter passphrase: " ssh_key_pass

echo -e "\n$green \bGenerating key pair: $ssh_key_name..."
ssh-keygen -t rsa -b 4096 -f $key_path/$ssh_key_name -C $ssh_key_name -P $ssh_key_pass

echo -e "\n$green \bSetting file permissions on key pair => 400..."
chmod u=r,go= $key_path/$ssh_key_name*
echo $blue; ls -l $key_path/$ssh_key_name

echo -e "\n$green \bSetting file permissions on public key => 644..."
chmod u=rw,go=r $key_path/$ssh_key_name.pub
echo $blue; ls -l $key_path/$ssh_key_name.pub

echo -e "\n$green \bCreating symlink to new private key from SSH directory..."
ln -sf $key_path/$ssh_key_name ~/.ssh

echo -e "\n$green \bAdd new private key to SSH Agent & OSX keychain..."
/usr/bin/ssh-add -K ~/.ssh/$ssh_key_name

if ssh-add -L | grep -q $ssh_key_name; then
  echo -e "$blue\n \bPrivate key added to SSH Agent..."
fi

echo -e "\n$green \bCopying public key payload to clipboard...$rs"
pbcopy < $key_path/$ssh_key_name.pub
