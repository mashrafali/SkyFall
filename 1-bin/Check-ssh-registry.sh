#! /bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

#Preparing variables
grep -v '^$' 2-servers/server-list > 4-temp/server-list
mv 4-temp/server-list 2-servers/server-list

echo
echo "## Checking Configuered servers @server-list"
echo
for serverip in $(cat 2-servers/server-list | awk {'print $1'})
do
  serverid=$(cat 2-servers/server-list | grep -i "$serverip " | awk {'print $2'})
  echo -en "######## Checking $serverip ["; echo -en '\E[20;34m'"\033[1m$serverid\033[0m"; echo -en "] : "
  ssh-copy-id root@$serverip 2>/dev/null
  echo "[OK]"
  echo
done

echo
echo "     Hit Enter to Continue..."
read
