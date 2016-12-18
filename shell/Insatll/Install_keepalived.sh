#!/bin/bash
tar zxf keepalived-1.2.20.tar.gz -C /usr/local/src/
cd  /usr/local/src/keepalived-1.2.20/
./configure --prefix=/usr/local/keepalived
make -j 4 && make install -j 4
mkdir /etc/keepalived
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
cp /usr/local/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/
cp /usr/local/keepalived/sbin/keepalived  /usr/bin/
service keepalived start


