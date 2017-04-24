#!/bin/bash
#检查mysql用户是否存在时，所用账户为zabbix 123456
#下面四个参数分别是mysql root登陆账户密码和zabbix新建用户密码
#zabbix不同版本间注意mysql导入数据的方式。
#在线下载的时候需要翻墙。

mysql_user="root"
mysql_passwd="123456"
zabbix_passwd="123456"
zabbix_user="zabbix"
function Install()
{
	read -p "请选择你的安装方式：local or inline" mothed
	if [ $mothed == "inline" ];then
		echo -n "download resource file……"
		echo http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$version/zabbix-$version.tar.gz
		wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$version/zabbix-$version.tar.gz --no-check-certificate> /dev/null 2>&1 && echo "OK"
		if [ $? -gt 0 ];then
				echo "Download Failed!"
				exit 1
		fi
	fi
	tar xf zabbix-$version.tar.gz -C /usr/local/src/
	tempdir=/usr/local/src/zabbix-$version/
	cd $tempdir
	mysql -uroot -p123456 zabbix<./database/mysql/schema.sql
	mysql -uroot -p123456 zabbix<./database/mysql/images.sql
	mysql -uroot -p123456 zabbix<./database/mysql/data.sql
	./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
	make -j 4 && make install -j 4
	config_path=`/usr/local/php/bin/php -i |grep configure|awk '{print $6}'|awk -F'=' '{print $2}'|sed "s/'//"`
	sed -i 's/post_max_size = 8M/post_max_size = 32M/' $config_path/php.ini 
	sed -i 's/max_execution_time = 30/max_execution_time = 300/' $config_path/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 300/' $config_path/php.ini
	sed -i 's/;date.timezone =/date.timezone =Asia\/shanghai/' $config_path/php.ini
	service php-fpm restart
	cp misc/init.d/fedora/core/zabbix_server /etc/init.d/zabbix_server
	cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/zabbix_agentd
	/bin/chmod +x /etc/init.d/zabbix_server
	/bin/chmod +x /etc/init.d/zabbix_agentd
	sed -i '/BASEDIR=/s/$/\/zabbix/' /etc/init.d/zabbix_*
	service zabbix_service start ;service zabbix_agentd start
	mkdir /usr/local/nginx/html/zabbix;cp ./frontends/php/* /usr/local/nginx/html/zabbix -R
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
	yum install net-snmp-devel -y
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
echo "*************检查mysql用户是否存在时，所用账户为zabbix 123456***********"
echo "*****下面四个参数分别是mysql root登陆账户密码和zabbix新建用户密码*******"
echo "*****************zabbix不同版本间注意mysql导入数据的方式。**************"
echo "**********************在线下载的时候需要翻墙。**************************"
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
		version=2.2.18
		;;
	2)	
		version=3.2.5
		;;
	3)	
		version=3.0.9
		;;
	*)
		version=3.0.9
		;;
esac
mysql -uzabbix -p123456 -e "show databases" 2&>1 /dev/null 
if [ $? -eq 0 ] ; then
	echo "user alrealy exsits"
else
	echo "create new mysql acount!please waiting..."
	newusername=$zabbix_user
	newuserpass=$zabbix_passwd
	sql_createdb="CREATE DATABASE IF NOT EXISTS $newusername;";
	sql_grant="grant all privileges on zabbix.* to '${newusername}'@'localhost' identified by '$newuserpass';";
	sql_flush="flush privileges; ";
	sql_add="${sql_createdb}${sql_grant}${sql_flush}";
	echo $sql_add; # 测试sql语句是否正常
	mysql --user=$mysql_user --password=$mysql_passwd --execute="$sql_add";
	sleep 3
	echo "user add scuessfull.."
fi

Install

