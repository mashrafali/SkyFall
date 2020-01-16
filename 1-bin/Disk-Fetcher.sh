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
echo "-----------------------------------------------------------------------------------------------" >  4-temp/server-disk
echo "|    Server IP    |       Hostname       |     Used Disk Space     |   Available Disk Space   |" >> 4-temp/server-disk
echo "-----------------------------------------------------------------------------------------------" >> 4-temp/server-disk


for serverip in $(cat 2-servers/server-list | awk {'print $1'})
do
  serverid=$(cat 2-servers/server-list | grep -i "$serverip " | awk {'print $2'})
  echo -en "## Calling SkyFall Cluster, Please be patient.......$progress% [$serverid]                    " \\r
  serverhost=$(ssh root@$serverip "hostname" 2> /dev/null)
  fetcherdata=$(ssh root@$serverip "df -h | grep '/$'" 2> /dev/null)
  if [ $serverip = "217.139.0.68" ]
  then
  diskused=$(echo $fetcherdata | awk {'print $2'})
  diskfree=$(echo $fetcherdata | awk {'print $3'})
  else
  diskused=$(echo $fetcherdata | awk {'print $3'})
  diskfree=$(echo $fetcherdata | awk {'print $4'})
  fi
  printf "|%17s|%22s|%25s|%26s| %s\n" "$serverip " "$serverhost  " "$diskused         " "$diskfree          "               >> 4-temp/server-disk
  progress=$(bc <<< "scale=1; $progress+$step")
done
echo -en "## Calling SkyFall Cluster, Please be patient.......100%    - Success -         " \\r && sleep 2
echo
echo "-----------------------------------------------------------------------------------------------" >> 4-temp/server-disk
cat 4-temp/server-disk
cp 4-temp/server-disk 3-data/Cluster-Disk
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
Subject: [SkyFall] Skyfall Cluster Disk Information
" > 4-temp/notificaton
cat 3-data/Table-Signature-Disk >> 4-temp/notificaton
for nserverip in $(cat 2-servers/server-list | awk {'print $1'})
do
   nserverhost=$(cat 3-data/Cluster-Disk | grep -i "$nserverip " | awk {'print $4'})
   ndiskused=$(cat 3-data/Cluster-Disk | grep -i "$nserverip " | awk {'print $6'})
   ndiskfree=$(cat 3-data/Cluster-Disk | grep -i "$nserverip " | awk {'print $8'})
   echo "  <tr>
    <td>$nserverip</td>
    <td>$nserverhost</td>
    <td>$ndiskused</td>
    <td>$ndiskfree</td>
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
