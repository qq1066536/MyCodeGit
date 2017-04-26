#!/bin/bash
#检查mysql用户是否存在时，所用账户为zabbix 123456
#下面四个参数分别是mysql root登陆账户密码和zabbix新建用户密码
#zabbix不同版本间注意mysql导入数据的方式。
#在线下载的时候需要翻墙。
cpu=`cat /proc/cpuinfo | grep "processor" | wc -l`
mysql_user="root"
mysql_passwd="123456"
zabbix_passwd="123456"
zabbix_user="zabbix"
function Install()
{
	if [ !-n $mothed ]; then
		if [ $mothed == "inline" ];then
			echo  "正在下载源码包，请稍后……"
			#echo http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$version/zabbix-$version.tar.gz
			wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$version/zabbix-$version.tar.gz --no-check-certificate &> /dev/null  && echo "OK"
			if [ $? -gt 0 ];then
					echo "Download Failed!"
					exit 1
			fi
		fi
	fi
	tar xf zabbix-$version.tar.gz -C /usr/local/src/
	tempdir=/usr/local/src/zabbix-$version/
	cd $tempdir
	echo  "正在导入数据库..."
	mysql -uroot -p123456 zabbix<./database/mysql/schema.sql
	mysql -uroot -p123456 zabbix<./database/mysql/images.sql
	mysql -uroot -p123456 zabbix<./database/mysql/data.sql
	echo  "开始源码编译zabbix"
	./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 &>/dev/null
	make -j $cpu  &>/dev/null && make install -j $cpu &>/dev/null
	echo  "正在配置环境"
	config_path=`/usr/local/php/bin/php -i |grep configure|awk '{print $6}'|awk -F'=' '{print $2}'|sed "s/'//"`
	sed -i 's/post_max_size = 8M/post_max_size = 32M/' $config_path/php.ini 
	sed -i 's/max_execution_time = 30/max_execution_time = 300/' $config_path/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 300/' $config_path/php.ini
	sed -i 's/;date.timezone =/date.timezone =Asia\/shanghai/' $config_path/php.ini
	service php-fpm restart
	cp misc/init.d/fedora/core/zabbix_server /etc/init.d/zabbix_server
	cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/zabbix_agentd
	sed -i "s/# DBPassword=/DBPassword=${zabbix_passwd}/" /usr/local/zabbix/etc/zabbix_server.conf
	/bin/chmod +x /etc/init.d/zabbix_server
	/bin/chmod +x /etc/init.d/zabbix_agentd
	sed -i '/BASEDIR=/s/$/\/zabbix/' /etc/init.d/zabbix_*
	service zabbix_server start ;service zabbix_agentd start
	mkdir /usr/local/nginx/html/zabbix;cp ./frontends/php/* /usr/local/nginx/html/zabbix -R
	echo "now can open http config"
}
function create_user()
{
	echo "create User zabbix....."
	groupadd zabbix
	useradd -r -s /sbin/nologin -g zabbix zabbix

}
clear
cat << EOF
"*************检查mysql用户是否存在时，所用账户为zabbix 123456***********"
"*****下面四个参数分别是mysql root登陆账户密码和zabbix新建用户密码*******"
"*****************zabbix不同版本间注意mysql导入数据的方式。**************"
"**********************在线下载的时候需要翻墙。**************************"
"************************************************************************"
"************************Please Choose Your Zabbix Version***************"
"************************************************************************"
"************************************************************************"
"1. ***************************2.2.18************************************"
"2. ***************************3.2.5*************************************"
"3. ***************************3.0.9(defaults)***************************"
echo "*******************************************************************"
EOF
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
read -p "请选择你的安装方式：local or inline ：" mothed

echo -n "正在安装依赖环境..."
a=`rpm -qa net-snmp-devel`
if [ ! $a ] ;then
	yum install net-snmp-devel -y &> /dev/null
else
	echo  'net-snmp-devel'
fi

echo  "检查zabbix用户是否存在..."
id zabbix 
if [ $? -eq 1 ] ; then
	create_user
else
	echo "User alreadly"
fi
mysql -uzabbix -p123456 -e "show databases" &> /dev/null 
if [ $? -eq 0 ] ; then
	echo "mysql用户已经存在"
else
	echo "为zabbix创建新的mysql用户"
	newusername=$zabbix_user
	newuserpass=$zabbix_passwd
	mysql -uzabbix -p123456 -e "drop database zabbix" &> /dev/null 
	sql_createdb="CREATE DATABASE IF NOT EXISTS $newusername;"
	sql_grant="grant all privileges on zabbix.* to '${newusername}'@'localhost' identified by '$newuserpass';"
	sql_flush="flush privileges; "
	sql_add="${sql_createdb}${sql_grant}${sql_flush}"
	mysql --user=$mysql_user --password=$mysql_passwd --execute="$sql_add" &>/dev/null
	sleep 3
	echo "mysql用户创建成功..."
fi

Install

