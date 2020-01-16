#! /bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

#Preparing variables
grep -v '^$' 2-servers/server-list > 4-temp/server-list
mv 4-temp/server-list 2-servers/server-list
number=$(cat 2-servers/server-list | wc -l)
step=$(bc <<< "scale=1; 100/$number")
let progress=0
echo

#Preparing Data File
echo "--------------------------------------------------------------------------------------------------------" >  4-temp/server-info
echo "|    Server IP    |       Hostname       |     Distribution Information     |      Kernel Version      |" >> 4-temp/server-info
echo "--------------------------------------------------------------------------------------------------------" >> 4-temp/server-info


for serverip in $(cat 2-servers/server-list | awk {'print $1'})
do
  serverid=$(cat 2-servers/server-list | grep -i "$serverip " | awk {'print $2'})
  echo -en "## Calling SkyFall Cluster, Please be patient.......$progress% [$serverid]                    " \\r
  serverdist=$(ssh root@$serverip "lsb_release -a | grep -i Description" 2> /dev/null | awk {'print $2"-"$3"-"$4'})
  serverkern=$(ssh root@$serverip "uname -r" 2> /dev/null)
  serverhost=$(ssh root@$serverip "hostname" 2> /dev/null)
  printf "|%17s|%22s|%34s|%26s| %s\n" "$serverip " "$serverhost  " "$serverdist     " "$serverkern "               >> 4-temp/server-info
  progress=$(bc <<< "scale=1; $progress+$step")
done
echo -en "## Calling SkyFall Cluster, Please be patient.......100%    - Success -         " \\r && sleep 2
echo
echo "--------------------------------------------------------------------------------------------------------" >> 4-temp/server-info
cat 4-temp/server-info
cp 4-temp/server-info 3-data/Cluster-Info
echo; echo -en "Send it via mail (y/n): "
read option
if [ -z "$option" ]
then
option=null
fi

#Mailing Information in HTML
if [ $option = "y" ]
then
echo -en "Mailing Information..."
echo "From: SkyFall@noor.net
To: logs-infra@noor.net
CC: mashraf@noor.net
MIME-Version: 1.0
Content-Type: text/html
Subject: [SkyFall] Skyfall Cluster Server Information
" > 4-temp/notificaton
cat 3-data/Table-Signature-Info >> 4-temp/notificaton
for nserverip in $(cat 2-servers/server-list | awk {'print $1'})
do
   nserverhost=$(cat 3-data/Cluster-Info | grep -i "$nserverip " | awk {'print $4'})
   nserverdist=$(cat 3-data/Cluster-Info | grep -i "$nserverip " | awk {'print $6'})
   nserverkern=$(cat 3-data/Cluster-Info | grep -i "$nserverip " | awk {'print $8'})
   echo "  <tr>
    <td>$nserverip</td>
    <td>$nserverhost</td>
    <td>$nserverdist</td>
    <td>$nserverkern</td>
  </tr>" >> 4-temp/notificaton
done
echo "</table>
</body>
</html>" >> 4-temp/notificaton
/usr/sbin/ssmtp -t < 4-temp/notificaton
fi
echo "[OK]"
echo
echo "     Hit Enter to Continue..."
read
