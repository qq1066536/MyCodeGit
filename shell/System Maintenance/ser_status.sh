#!/bin/bash
mkdir /tmp/ser
file=/tmp/ser/server_status.txt
ifconfig |grep Bcast|awk '{print $2}'|awk -F: '{print $2}' > $file
diff $file /root/server_status/ip.txt
if [ $? -ne 0 ] ; then
	echo "server IP is Changed!" > $file
else
	echo "server IP is Nochanged!" > $file
fi
echo "online user:" >> $file
w |awk '{print $1 "\t" $3 }'|grep -v ^[0-9] >>$file
uptime|awk '{print $3}'|awk -F, '{print "uptime:"$1}' >>$file
uptime|awk '{print "cpu avg:"$8 $9 $10}' >>$file
free -m |grep ^Mem |awk '{print "Mem:"int($3/$2*100)"%"}'>>$file
services=(ssh mysqld rsyslog)
#echo ${services[@]}
for service in ${services[@]}
do
	netstat -anptu|grep $service &>/dev/null 
	if [ $? -eq 0 ] ; then
		echo "$service is running!" >>$file
	else
		
		echo "$service not running!">>$file

	fi
done
echo "磁盘空间占有情况" >> $file
df -h |awk '{print $5 "\t" $6}' |sed -n '1,4p' >> $file
mail -s "server_status" 1@1.net <$file
cat $file
rm -rf /tmp/ser/
