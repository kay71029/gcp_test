###
yum update -y 

### 網路相關
yum -y install telnet traceroute tcpdump lsof
### 文件相關
yum -y install tree mtr ansible inotify-tools psmisc 
### 硬碟相關
yum -y install cloud-utils-growpart
### 其他
yum -y install uuid lrzsz  numactl htop

rpm -qa | grep vim
yum -y install vim*
yum install vim-enhanced -y
vim --version

#===================
#git,wget
#===================
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker wget -y
cd /tmp/;wget https://www.kernel.org/pub/software/scm/git/git-2.18.0.tar.gz
tar xvzf /tmp/git-2.18.0.tar.gz
cd git-2.18.0
make prefix=/usr/local/git all;make prefix=/usr/local/git install
cd /usr/bin/;ln -fs /usr/local/git/bin/git* .

#============
#mysql
#============
yum -y install mariadb.x86_64
mysql -V

#===================
#start-stop-daemon
#===================
cd /tmp
wget http://developer.axis.com/download/distribution/apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz
tar zxvf apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz
cd /tmp/apps/sys-utils/start-stop-daemon-IR1_9_18-2
gcc start-stop-daemon.c -o start-stop-daemon
cp start-stop-daemon /usr/sbin/
rm -rf /tmp/apps
rm -rf /tmp/apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz


#============
#memcached
#============

cd /tmp;wget http://www.memcached.org/files/memcached-1.4.24.tar.gz
cd /tmp;tar zxvf memcached-1.4.24.tar.gz
chown -R root:root memcached-1.4.24
cd memcached-1.4.24
yum -y install libevent libevent-devel 
./configure --prefix=/usr/local/memcached
make && make install
cd /usr/bin/;ln -fs /usr/local/memcached/bin/memcached

#============
#redis
#============
yum -y install yum-utils  
yum -y  install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi
yum -y install redis


#============
#nginx 
#============
cd /tmp;git clone https://github.com/kay71029/gcp_test.git
cd /tmp;tar xvf /tmp/headers-more-nginx-module-master.tar.gz
mkdir -p /usr/local/web/nginx
cd /tmp;wget http://nginx.org/download/nginx-1.8.1.tar.gz
cd /tmp;tar zxvf nginx-1.8.1.tar.gz ;chown -R root:root nginx-1.8.1
cd /tmp/nginx-1.8.1
./configure --prefix=/usr/local/web/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/usr/local/web/nginx/logs/nginx.pid --with-http_ssl_module --with-http_gzip_static_module --with-poll_module --with-http_stub_status_module --add-module=/tmp/headers-more-nginx-module-master
make & make install
/usr/local/web/nginx/sbin/nginx -v
cd /usr/bin;ln -fs /usr/local/web/nginx/sbin/nginx

cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=Nginx - a high performance http(s) server
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/usr/local/web/nginx/sbin/nginx
ExecReload=/usr/local/web/nginx/sbin/nginx -s reload
[Install]
WantedBy=multi-user.target
EOF

#============
#gearmand
#============
yum install -y boost boost-devel gperf gperf-devel libevent libevent-devel libuuid libuuid-devel php-devel libgearman libgearman-devel
yum install -y zypper in gcc gcc-c++
cd /tmp;wget https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz
cd /tmp/;tar -xvf gearmand-1.1.12.tar.gz
chown -R root:root gearmand-1.1.12
cd /tmp/gearmand-1.1.12; ./configure --prefix=/usr/local/gearmand --disable-libpq;
make;make install
cp /usr/local/gearmand/bin/gearman /usr/bin
cp /usr/local/gearmand/bin/gearman /usr/local/bin
cp /usr/local/gearmand/bin/gearadmin /usr/bin
cp /usr/local/gearmand/sbin/gearmand /usr/bin


cd /tmp;wget https://www.php.net/distributions/php-5.5.28.tar.gz
cd /tmp;tar -xvf php-5.5.28.tar.gz
chown -R root:root php-5.5.28
yum install libxml2 libxml2-devel libmcrypt libjpeg-devel libpng libpng-devel freetype-devel libicu-devel glibc-headers gcc-c++ php-mcrypt  libmcrypt  libmcrypt-devel autoconf libgearman -y
mkdir -p /usr/local/web/php
./configure --prefix=/usr/local/web/php --with-config-file-path=/etc --with-mcrypt=/usr --with-openssl --with-mysql-sock --with-gd --with-jpeg-dir=/usr/lib --with-libxml-dir=/usr/lib --with-curl --with-iconv --with-gettext --with-freetype-dir=/usr --with-fpm-user=nobody --with-fpm-group=nobody --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --enable-mbstring --enable-fpm --enable-gd-native-ttf --enable-zip --enable-sockets --enable-exif --enable-ftp --enable-intl --enable-pcntl --enable-bcmath --enable-sysvshm --enable-sysvsem --with-zlib
make;make install
/usr/local/web/php/bin/php -v
cp /home/git/no-debug-non-zts-20121212.tar.gz /tmp;
tar zxvf no-debug-non-zts-20121212.tar.gz 
chown -R root:root no-debug-non-zts-20121212.tar.gz
cd /usr/local/web/php/lib/php/extensions/no-debug-non-zts-20121212;
cp /tmp/no-debug-non-zts-20121212/apcu.so .
cp /tmp/no-debug-non-zts-20121212/gearman.so
cp /tmp/no-debug-non-zts-20121212/gearman.so .
cp /tmp/no-debug-non-zts-20121212/memcache.so .
cp /tmp/no-debug-non-zts-20121212/redis.so .
cp /tmp/no-debug-non-zts-20121212/uuid.so .
cd /usr/bin;ln -fs /usr/local/web/php/bin/php

cat > /usr/lib/systemd/system/php-fpm.service <<EOF
[Unit]
Description=The PHP FastCGI Process Manager
After=syslog.target network.target
[Service]
Type=simple
PIDFile=/var/run/php-fpm.pid
ExecStart=/usr/local/web/php/sbin/php-fpm --nodaemonize --fpm-config /etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
[Install]
WantedBy=multi-user.target
EOF

