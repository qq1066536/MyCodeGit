#!/bin/bash
function Install()
{
	tar zxf zabbix-$version.tar.gz -C /usr/local/src/
	tempdir=/usr/local/src/zabbix-$version/
	cd $tempdir
	mysql -uroot -p123456 zabbix<./database/mysql/schema.sql
	mysql -uroot -p123456 zabbix<./database/mysql/images.sql
	mysql -uroot -p123456 zabbix<./database/mysql/data.sql
	./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
	make -j 4 && make install -j 4
	sed -i 's/post_max_size = 8M/post_max_size = 32M/' /etc/php.ini 
	sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 300/' /etc/php.ini
	sed -i 's/;date.timezone =/date.timezone =Asia\/shanghai/' /etc/php.ini
	service php-fpm restart
	cp misc/init.d/fedora/core/zabbix_server /etc/init.d/zabbix_server
	/bin/chmod +x /etc/init.d/zabbix_server
	service zabbix_service start
	echo "now can open http config"
}
function create_user()
{
	echo "create User zabbix....."
	groupadd zabbix
	useradd -r -s /sbin/nologin -g zabbix zabbix
	echo zabbix:123456|chpasswd

}
a=`rpm -qa net-snmp-devel`
if [ ! $a ] ;then
	yum install net-snmp-devel
else
	echo  'net-snmp-devel'
fi
id zabbix 
if [ $? -eq 1 ] ; then
	create_user
else
	echo "User alreadly"
fi

clear
echo "************************************************************************"
echo "************************Please Choose Your Zabbix Version***************"
echo "************************************************************************"
echo "************************************************************************"
echo "1. ***************************2.2***************************************"
echo "2. ***************************2.4***************************************"
echo "3. ***************************3.0(defaults)*****************************"
echo "************************************************************************"
read -p "Please Enter you choose " ver
case $ver in 
	1)
		version=2.2.16
		;;
	2)	
		version=3.2.2
		;;
	3)	
		version=3.0.6
		;;
	*)
		version=3.0.6
		;;
esac
mysql -uzabbix -p123456 -e "show databases" 2&>1 /dev/null 
if [ $? -eq 0 ] ; then
	echo "user alrealy exsits"
else
	newusername="zabbix"
	newuserpass="123456"
	sql_createdb="CREATE DATABASE IF NOT EXISTS $newusername;";
	sql_grant="grant all privileges on zabbix.* to '${newusername}'@'localhost' identified by '$newuserpass';";
	sql_flush="flush privileges; ";
	sql_add="${sql_createdb}${sql_grant}${sql_flush}";
	echo $sql_add; # 测试sql语句是否正常
	mysql --user=root --password=123456 --execute="$sql_add";
fi

Install

