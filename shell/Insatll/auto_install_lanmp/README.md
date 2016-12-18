1、直接运行auto_install.sh 脚本自动执行
2、auto_clean.sh在源码包目录下。cd命令路径中不能传入变量（末尾除外）
3、所需源码包：
	apr-1.4.5.tar.gz        jpegsrc.v9a.tar.gz      ncurses-5.7.tar.gz
	apr-util-1.3.12.tar.gz  libiconv-1.13.1.tar.gz  nginx-1.10.1.tar.gz
	libmcrypt-2.5.7.tar.gz  pcre-8.32.tar.gz		mysql-5.6.22.tar.gz
	cmake-2.8.5.tar.gz      libpng-1.6.16.tar.gz    php-7.0.7.tar.gz
	freetype-2.5.5.tar.gz   libxml2-2.6.30.tar.gz   zlib-1.2.8.tar.gz
	gd-2.0.35.tar.gz        mcrypt-2.6.8.tar.gz		httpd-2.4.10.tar.gz  
4、此代码只负责安装，不负责配置，请自行修改配置文件
5、路漫漫其修远兮 吾将shell来求索。初步接触，如有错误自行修改。
	注：nginx 为nginx的启动脚本