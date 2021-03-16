#####################
# 1) 更新 套件
#####################
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

yum install epel-release -y
yum -y install supervisor

#===================
#2)安裝 git,wget
#===================
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker wget -y
cd /tmp/;wget https://www.kernel.org/pub/software/scm/git/git-2.18.0.tar.gz
tar xvzf /tmp/git-2.18.0.tar.gz
cd git-2.18.0
make prefix=/usr/local/git all;make prefix=/usr/local/git install
cd /usr/bin/;ln -fs /usr/local/git/bin/git* .

#============
#3)安裝 mysql
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
#4)安裝 memcached
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
#5)安裝 redis
#============
yum -y install yum-utils  
yum -y  install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi
yum -y install redis


#============
#6)安裝 nginx 
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

cat > /etc/logrotate.d/nginx <<EOF
/var/log/nginx/*.log /var/log/nginx/json/*.json {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    sharedscripts
    prerotate
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
        run-parts /etc/logrotate.d/httpd-prerotate; \
    fi; \
    endscript
    postrotate
    /usr/local/web/nginx/sbin/nginx -s reload
    endscript
}
EOF

#============
#7)安裝 gearmand
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

cat > /etc/logrotate.d/php-fpm <<EOF
/var/log/php-fpm/php-fpm.access.log {
    daily
    create
    missingok
    rotate 7
    compress
    notifempty
    dateext
    sharedscripts
    postrotate
    if [ -f /var/run/php-fpm.pid ]; then
        /bin/kill -USR1 `cat /var/run/php-fpm.pid`
    fi
    endscript
}
EOF


#============
#8)安裝 td-agent
#============
yum -y install geoip-bin geoip-database libgeoip-dev ;yum install -y  GeoIP GeoIP-devel GeoIP-data libmaxminddb-devel
yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel libffi-deve openssl-devel make bzip2 autoconf automake libtool bison sqlite-devel
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh

td-agent-gem install elasticsearch
td-agent-gem install fluent-plugin-geoip-filter
td-agent-gem install fluent-plugin-record-reformer
td-agent-gem install fluent-plugin-rewrite-tag-filter
td-agent-gem install fluent-plugin-filter_where
td-agent-gem install fluent-plugin-concat
td-agent-gem install fluent-plugin-grep
td-agent-gem install parser
td-agent-gem install fluent-plugin-filter-urldecode
td-agent-gem install fluent-plugin-mail
td-agent-gem install fluent-plugin-groupcounter
td-agent-gem install fluent-plugin-extract_query_params
td-agent-gem install fluent-plugin-elapsed-time
td-agent-gem install fluent-plugin-td-monitoring
td-agent-gem install fluent-plugin-geoip
td-agent-gem install fluent-plugin-grok-parser
td-agent-gem install kafka

#============
#9)系統設定
#============

function change_limit(){
    echo "配置扩展文件"
    echo "*          soft    core      102400" >> /etc/security/limits.d/20-nproc.conf
    echo "*          hard    core      102400" >> /etc/security/limits.d/20-nproc.conf
    echo "*          soft    nofile    65535" >> /etc/security/limits.d/20-nproc.conf
    echo "*          hard    nofile    65535" >> /etc/security/limits.d/20-nproc.conf
    echo "*          soft    nproc     65535" >> /etc/security/limits.d/20-nproc.conf
    echo "*          hard    nproc     65535" >> /etc/security/limits.d/20-nproc.conf

    cat /etc/security/limits.d/20-nproc.conf
}

function change_selinux(){
    echo "关闭SELinux"
    sed -i '7s/enforcing/disabled/' /etc/selinux/config
    cat /etc/selinux/config
    /usr/sbin/sestatus -v
}

function change_bashrc(){
    echo "bashrc add "
    echo 'export HISTTIMEFORMAT="%F %T "' >> /etc/bashrc
    echo 'PS1="\[\e[1;36m\]\u\[\e[34m\]@\[\e[33m\]\H\[\e[35m\][\w]\[\e[0m\]\\$"' >> /etc/bashrc
    cat /etc/bashrc
}

function change_sysctl(){
    echo "#表示開啟TCP連接中TIME-WAIT sockets的快速回收，默認為0，表示關閉" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_tw_recycle = 1" >>/etc/sysctl.conf
    echo "##表示開啟重用。允許將TIME-WAIT sockets重新用於新的TCP連接，默認為0，表示關閉" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf

    echo "#降低 swappiness 的數值" >>/etc/sysctl.conf
    echo "vm.swappiness = 30" >>/etc/sysctl.conf
    echo "#修改核心引數禁止OOM機制 1表示關閉，預設為0表示開啟OOM" >>/etc/sysctl.conf
    echo "vm.panic_on_oom = 1" >>/etc/sysctl.conf

    echo "#網絡設備接收數據包的速率比內核處理這些包的速率快時，允許送到隊列的數據包的最大數目" >>/etc/sysctl.conf
    echo "net.core.netdev_max_backlog=65535" >>/etc/sysctl.conf
    echo "#表示SYN隊列長度，默認1024，改成 65535，可以容納更多等待連接的網絡連接數" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog=65535" >>/etc/sysctl.conf
    echo "#指定了接收套接字緩衝區大小的最大值（以字節為單位）" >>/etc/sysctl.conf
    echo "net.core.somaxconn=65535" >>/etc/sysctl.conf

    echo "#表示當keepalive起用的時候，TCP發送keepalive消息的頻度。預設是2小時，改為5分鐘" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_keepalive_time =300" >>/etc/sysctl.conf
    echo "#keepalive探測包的發送間隔" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_keepalive_intvl = 15" >>/etc/sysctl.conf
    echo "#如果對方不予應答，探測包的發送次數" >>/etc/sysctl.conf
    echo "net.ipv4.tcp_keepalive_probes = 5" >>/etc/sysctl.conf

}

function chage_sudo(){
    rpm -Uvh https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo-1.9.5-3.el7.x86_64.rpm
    sudoedit -s
}

change_limit
change_selinux
change_bashrc
change_sysctl
chage_sudo
