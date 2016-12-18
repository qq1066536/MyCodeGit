#!/bin/bash
yum -y remove http*
yum -y install gcc gcc-c++
url=/root/test/tar_gz
cd $url/apr-1.4.5
./configure --prefix=/usr/local/apr/
make
make install  

cd $url/apr-util-1.3.12
./configure --prefix=/usr/local/apr-util/ --with-apr=/usr/local/apr/
make 
make install 


cd $url/pcre-8.32
./configure --prefix=/usr/local/pcre/
make
make install 

cd $url/httpd-2.4.10
./configure  --prefix=/usr/local/apache2/  --enable-so  --with-apr=/usr/local/apr/ --with-apr-util=/usr/local/apr-util/ --with-pcre=/usr/local/pcre/ --enable-modules=most
make 
make install 

