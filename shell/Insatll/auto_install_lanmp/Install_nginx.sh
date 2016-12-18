#!/bin/bash
url=/root/test/tar_gz
yum -y install openssl openssl-devel
#clear
#echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
#echo '+++++++++++++++++++++++++++++++++++Installing pcre++++++++++++++++++++++++++++++++'
#echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
#cd $url/pcre-8.32/
#./configure --prefix=/usr/local/pcre/
#make -j 4 && make install -j 4

clear
echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo '+++++++++++++++++++++++++++++++++++Installing Zlib++++++++++++++++++++++++++++++++'
echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

cd $url/zlib-1.2.8
./configure --prefix=/usr/local/zlib/
make -j 4 && make install -j 4

clear
echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo '+++++++++++++++++++++++++++++++++++Installing Nginx Server++++++++++++++++++++++++'
echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

cd $url/nginx-1.10.1
 ./configure --prefix=/usr/local/nginx --with-http_dav_module --with-http_stub_status_module --with-http_addition_module --with-http_sub_module --with-http_flv_module --with-http_mp4_module --with-pcre=$url/pcre-8.32
make -j 4 && make install -j 4
cp /root/test/sh/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
service nginx start
