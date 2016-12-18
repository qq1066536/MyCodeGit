#!/bin/bash
url=/root/test/tar_gz
cd $url/libpng-1.6.16
./configure --prefix=/usr/local/libng
make
make install

cd $url/freetype-2.5.5
./configure --prefix=/usr/local/freetype
make
make install

cd $url/libiconv-1.13.1/
./configure --prefix=/usr/local/libiconv
make
make install

cd $url/libxml2-2.6.30
./configure --prefix=/usr/local/libxml
make
make install

cd $url/jpeg-9a/
./configure --prefix=/usr/local/libjpeg --enable-shared --enable-static
make
make install
ln -s /usr/local/libjpeg/lib/* /usr/lib/

cd $url/freetype-2.5.5
./configure --prefix=/usr/local/freetype
make
make install

cd $url/libmcrypt-2.5.7
./configure --prefix=/usr/local/libmcrypt
make
make install

cd $url/gd-2.0.35
./configure --prefix=/usr/local/gd2 --with-png=/usr/local/libpng --with-libiconv-prefix=/usr/local/libiconv --with-freetype=/usr/local/freetype --with-jpeg=/usr/local/libjpeg --with-fontconfig=/usr/local/fontconfig/ --enable-m4_pattern_allow
make
make install
echo "/usr/local/libmcrypt/lib">>/etc/ld.so.conf
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
ldconfig
cd $url/php-7.0.7
./configure \
--prefix=/usr/local/php \
--with-config-file-path=/etc \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir=/usr/local/libjpeg \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--with-curlwrappers \
--enable-mbregex \
--enable-fpm \
--enable-mbstring \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--with-mcrypt-dir=/usr/local/libmcrypt \
--with-gettext \
--with-libdir=lib64
make -j 4 && make install -j 4
cp ./php.ini-production /etc/php.ini
cp  ./sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
service php-fpm start
