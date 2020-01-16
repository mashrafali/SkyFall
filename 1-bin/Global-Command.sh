#! /bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

#Preparing variables
grep -v '^$' 2-servers/server-list > 4-temp/server-list
mv 4-temp/server-list 2-servers/server-list
cat 3-data/logo.asci | head -9
echo
echo "# Enter the Command you would like to Execute Globally:"
echo
read -e -p 'root@EveryWhere:~# ' command
echo
echo "Starting Dial Run..."
echo
for serverip in $(cat 2-servers/server-list | awk {'print $1'})
do
  serverid=$(cat 2-servers/server-list | grep -i "$serverip " | awk {'print $2'})
  echo -en "######### Dialing $serverip ["; echo -en '\E[20;34m'"\033[1m$serverid\033[0m"; echo "] : "
  ssh root@$serverip "$command"
  echo
done

echo "[OK]"
echo
echo "     Hit Enter to Continue..."
read
