#!/bin/bash
#by caosm 
#time 20161122
#2016-11-30 我们的故事|静静的聆听（1066536184） 
#注意： 1、缩进问题
#		2、严谨性
#		3、精简至上原则   
ipaddr(){
echo "===============配置ip地址以及主机名称==========="
read -p "请输入你的ip地址：" IPADDR
read -p "请输入你的子网掩码：" NETMASK 
read -p "请输入你的网关地址：" GATEWAY
read -p "请输入你的DNS1：" DNS1

sed -i  '/^ONBOOT/s/no/yes/' $netmasker
sed -i  '/^BOOTPROTO/s/dhcp/static/' $netmasker
sed -i "/^IPADDR/s/[0-9].\+/$IPADDR/ "  $netmasker
sed -i "/^NETMASK/s/[0-9].\+/$NETMASK/ "  $netmasker
sed -i "/^GATEWAY/s/[0-9].\+/$GATEWAY/ "  $netmasker
sed -i "/^DNS1/s/\[0-9].\+/$DNS1/ "  $netmasker
service  network restart >&/dev/null
	ping -c 3 -w 5 www.baidu.com >&/dev/null
	if  [[ $? != 0 ]];then
		echo " 不能上网请检查配置 "
	else
		echo -e "\033[32;1m=====================NetWork Already Configure Finish ============================\033[0m"	
    fi
sleep 2
}
#HOSTNAME
ip_hostname(){
echo "==================配置主机名称===================="
read  -p "请输入你的主机名称：" HOSTNAME
sed -i '3,$d' /etc/hosts
sed -i '2,$d' /etc/sysconfig/network
#sed -i  '/^HOSTNAME.*$/d' $netmasker

sed -i  '/^HOSTNAME.*$/d' /etc/hosts
#`cat $netmasker|grep ^HOSTNAME`
#if [ $? -eq 0 ];then
#	sed -i  '/^HOSTNAME/s/=$/$HOSTNAME/' $netmasker
#else
	echo "HOSTNAME=$HOSTNAME" >> /etc/sysconfig/network
#fi
IPADDR=`ip a  | grep "global eth0" | awk '{print $2}' | awk -F "/" '{print $1}'`
echo -e "$IPADDR\t$HOSTNAME" >>/etc/hosts
#echo -n  " $HOSTNAME" >> /etc/hosts
echo "================主机名配置成功===================================="
echo ""
sleep 2
}
# yum_163
configYum(){
echo "================更新为国内YUM源=================="
	cd /etc/yum.repos.d/
	#cp CentOS-Base.repo CentOS-Base.repo.$(date +%F)
    #rename *.repo{,.$(date +%F)
    ping -c 1 www.163.com>/dev/null
	if [ $? -eq 0 ];then
		beta=`cat /etc/redhat-release |awk '{print $7}'|awk -F. '{print $1}'`
		echo $beta
		if [ $beta -ge 7 ] ;then
			if [ -f CentOS7-Base-163.repo ]; then
				mv CentOS7-Base-163.repo{,.$(date +%F)}
			fi
			
			wget -q http://mirrors.163.com/.help/CentOS7-Base-163.repo >/dev/null
			sleep 2
        		sed -i "s/\$releasever/7/g" CentOS7-Base-163.repo
		elif [ $beta -ge 6 ] ; then
			if [  -f CentOS6-Base-163.repo ] ;then
       				mv CentOS6-Base-163.repo{,.$(date +%F)}
			fi
			wget -q  http://mirrors.163.com/.help/CentOS6-Base-163.repo >/dev/null
			sleep 2
        		sed -i "s/\$releasever/6.8/g" CentOS6-Base-163.repo
		fi
	else
		echo "无法连接网络。"
		exit $?
	fi
	#cp CentOS-Base-sohu.repo CentOS-Base.repo
echo -e "\033[32;1m==================正在更新YUM源配置===============================\033[0m"
	yum clean all >> /dev/null
	yum list >>/dev/null
#	yum makecache  >& /dev/null
#action "配置国内YUM完成"  /bin/true
echo -e "\033[32;1m==================配置YUM源完成===============================\033[0m"
echo ""
sleep 2
}
#time sync
syncSysTime(){
echo "================配置时间同步====================="
  \cp /var/spool/cron/root /var/spool/cron/root.$(date +%F) 2>/dev/null
  NTPDATE=`grep ntpdate /var/spool/cron/root 2>/dev/null |wc -l`
  if [ $NTPDATE -eq 0 ];then
    echo "#times sync by lee at $(date +%F)" >>/var/spool/cron/root
    echo "*/5 * * * * /usr/sbin/ntpdate time.windows.com >/dev/null 2>&1" >> /var/spool/cron/root
  fi
    #echo -e '\033[31;1m'`cat /var/spool/cron/root` '\033[0m'   #不能用shell获取计划任务信息，会ls当前目录
  #$(crontab -l)
#action "配置时间同步完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Charset zh_CN.UTF-8
initI18n(){
echo "================更改为中文字符集================="
  \cp /etc/sysconfig/i18n /etc/sysconfig/i18n.$(date +%F)
  echo "LANG="zh_CN.UTF-8"" >/etc/sysconfig/i18n
  source /etc/sysconfig/i18n
  echo '#cat /etc/sysconfig/i18n'
  grep LANG /etc/sysconfig/i18n
#action "更改字符集zh_CN.UTF-8完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Close Selinux and Iptables
Firewall(){
echo "============禁用SELINUX及关闭防火墙=============="
cp /etc/selinux/config /etc/selinux/config.$(date +%F)
/etc/init.d/iptables status >> /dev/null
if [ $? -eq 0 ]; then	#判断防火墙是否开启，开启时返回值是0
    /etc/init.d/iptables stop >>/dev/null
fi
$(cat /etc/selinux/config  |grep SELINUX=enforcing)
if [ $? -eq 0 ] ;then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
#getenforce 
#action "禁用selinux及关闭防火墙完成" /bin/true
echo "==================防火墙关闭成功！==============================="
echo ""
  sleep 2
}
#menu2
menu2(){
while true
do
clear
cat << EOF
----------------------------------------
|****Please Enter Your Choice:[0-6]****|
----------------------------------------
(1) 配置ip地址以 
(2) 配置为国内YUM源镜像
(3) 设置时间同步
(4) 配置中文字符集
(5) 禁用SELINUX及关闭防火墙
(6) 配置主机名称
(0) 返回上一级菜单
EOF
read -p "Please enter your Choice[0-6]: " input2
case "$input2" in
  0)
  clear
  break
  ;;
  1)
  ipaddr
  ;;
  2)
  configYum
  ;;
  3)
  syncSysTime
  ;;
  4)
  initI18n
  ;;
  5)
  Firewall
  ;;
  6)
  ip_hostname
  ;; 
  *) 
  Warning
  ;;
esac
done
}
#menu
main(){
while true
do
clear
echo "========================================"
echo '          Linux Optimization            '   
echo "========================================"
cat << EOF
|-----------System Infomation-----------
| DATE       :$DATE
| HOSTNAME   :$HOSTNAME
| USER       :$USER
| IP         :$IPADDR
| DISK_USED  :$DISK_SDA
| CPU_AVERAGE:$cpu_uptime
----------------------------------------
|****Please Enter Your Choice:[1-3]****|
----------------------------------------
(1) 一键优化
(2) 自定义优化
(3) 退出
EOF
#choice
read -p "Please enter your choice[0-3]: " input1
    case "$input1" in
    1) 
        ip_hostname
        configYum
        syncSysTime
        initI18n
        Firewall
        hostname
        ;;

    2)
        menu2
        ;;
    3) 
        clear 
        break
        ;;
    *)   
	    Warning
	    ;;
    esac  
done
}
Warning(){
  echo "----------------------------------"
  echo "|          Warning!!!            |"
  echo "|   Please Enter Right Choice!   |"
  echo "----------------------------------"
  sleep 2
 ((ErrorNo+=1))
    if [ $ErrorNo -eq 3 ];then  #判断错误次数，已达到自动退出目的
        echo -e '\033[31;1mError So Much ,The Script  Exiting!\033[0m'
        sleep 5 

        exit
    fi
  clear
}
if [ $UID -ne 0 ];then
	echo 'must use Root run this script!'
    exit 1
else
#获取一些初始变量，磁盘使用情况未配置
    ErrorNo=0
    DATE=$(date +%F)
    DISK_SDA=$(df -h |grep "/$"|awk '{print $5}')
    IPADDR=`ifconfig |grep broad|awk '{print $2}'`
    cpu_uptime=`uptime|awk -F: '{print $4}'`
    netmasker=`ls /etc/sysconfig/network-scripts/ifcfg-e*`
    main
fi	

