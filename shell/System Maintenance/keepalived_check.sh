#!/bin/bash
while  :
do
mysqlcheck=`ps -C mysqld --no-header | wc -l`
phpcheck=`ps -C php-fpm --no-header | wc -l`
nginxcheck=`ps -C httpd --no-header | wc -l`
keepalivedcheck=`ps -C keepalived --no-header | wc -l`
if [ $nginxcheck -eq 0 ]|| [ $phpcheck -eq 0 ]||[ $mysqlcheck -eq 0 ];then
	if [ $keepalivedcheck -ne 0 ];then
	   killall -TERM keepalived
	else
	   echo "keepalived is stoped">>/var/log/keepalived.log
	fi
else
	if [ $keepalivedcheck -eq 0 ];then
	   /etc/init.d/keepalived start
	else
	   echo "keepalived is running">>/var/log/keepalived.log

	fi
fi
sleep 5
done
