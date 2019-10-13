#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear;
echo '================================================================';
echo ' [LNMP/Nginx] Amysql Host - AMH 4.2 ';
echo ' http://Amysql.com';
echo '================================================================';


# VAR ***************************************************************************************
AMHDir='/home/amh_install/';
SysName='';
SysBit='';
Cpunum='';
RamTotal='';
RamSwap='';
InstallModel='';
Release=`cat /etc/*release /etc/*version 2>/dev/null | grep -Eo '([0-9]{1,2}\.){1,3}' | cut -d '.' -f1 | head -1`;
Domain=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`;
MysqlPass='';
AMHPass='';
StartDate='';
StartDateSecond='';
PHPDisable='';

# Version
AMSVersion='ams-1.5.0107-02';
AMHVersion='amh-4.2';
LibiconvVersion='libiconv-1.16';
MysqlVersion='mysql-5.5.62';
PhpVersion='php-5.6.40';
NginxVersion='tengine-2.3.2';
PureFTPdVersion='pure-ftpd-1.0.36';
BoostVersion='boost_1_60_0';

# Function List	*****************************************************************************
function CheckSystem()
{
	[ $(id -u) != '0' ] && echo '[Error] Please use root to install AMH.' && exit;
	egrep -i "debian" /etc/issue /proc/version >/dev/null && SysName='Debian';
	egrep -i "ubuntu" /etc/issue /proc/version >/dev/null && SysName='Ubuntu';
	whereis -b yum | grep '/yum' >/dev/null && SysName='CentOS';
	[ "$SysName" == ''  ] && echo '[Error] Your system is not supported install AMH' && exit;

	SysBit='32' && [ `getconf WORD_BIT` == '32' ] && [ `getconf LONG_BIT` == '64' ] && SysBit='64';
	Cpunum=`cat /proc/cpuinfo | grep 'processor' | wc -l`;
	echo "${SysName}${Release} ${SysBit}Bit";
	RamTotal=`free -m | grep 'Mem' | awk '{print $2}'`;
	RamSwap=`free -m | grep 'Swap' | awk '{print $2}'`;
	echo "Server ${Domain}";
	echo "${CpuNum}*CPU, ${RamTotal}MB*RAM, ${RamSwap}MB*Swap";
	echo '================================================================';

	RamSum=$[$RamTotal+$RamSwap];
	[ "$SysBit" == '32' ] && [ "$RamSum" -lt '64' ] && \
	echo -e "[Error] Not enough memory install AMH. \n(32bit system need memory: ${RamTotal}MB*RAM + ${RamSwap}MB*Swap > 250MB)" && exit;

	if [ "$SysBit" == '64' ] && [ "$RamSum" -lt '128' ];  then
		echo -e "[Error] Not enough memory install AMH. \n(64bit system need memory: ${RamTotal}MB*RAM + ${RamSwap}MB*Swap > 480MB)";
		[ "$RamSum" -gt '250' ] && echo "[Notice] Please use 32bit system.";
		exit;
	fi;

	[ "$RamSum" -lt '600' ] && PHPDisable='--disable-fileinfo';
}

function ConfirmInstall()
{
	echo "[Notice] Confirm Install/Uninstall AMH? please select: (1~3)"
	select selected in 'Install AMH 4.2' 'Uninstall AMH 4.2' 'Exit'; do break; done;
	[ "$selected" == 'Exit' ] && echo 'Exit Install.' && exit;

	if [ "$selected" == 'Install AMH 4.2' ]; then
		InstallModel='1';
	elif [ "$selected" == 'Uninstall AMH 4.2' ]; then
		Uninstall;
	else
		ConfirmInstall;
		return;
	fi;

	echo "[OK] You Selected: ${selected}";
}

function SelectPHP()
{
	echo "[Notice] Please select PHP version you would like to use: (default PHP 5.6)"
	select selected in 'PHP 5.3' 'PHP 5.4' 'PHP 5.5' 'PHP 5.6' 'PHP 7.1' 'PHP 7.2' 'PHP 7.3'; do break; done;

	if [ "$selected" == 'PHP 5.3' ]; then
		PhpVersion='php-5.3.29';
	elif [ "$selected" == 'PHP 5.4' ]; then
		PhpVersion='php-5.4.45';
	elif [ "$selected" == 'PHP 5.5' ]; then
		PhpVersion='php-5.5.38';
	elif [ "$selected" == 'PHP 5.6' ]; then
		PhpVersion='php-5.6.40';
	elif [ "$selected" == 'PHP 7.0' ]; then
		PhpVersion='php-7.0.33';
	elif [ "$selected" == 'PHP 7.1' ]; then
		PhpVersion='php-7.1.32';
	elif [ "$selected" == 'PHP 7.2' ]; then
		PhpVersion='php-7.2.22';
	elif [ "$selected" == 'PHP 7.3' ]; then
		PhpVersion='php-7.3.9';
		PHPDisable='--without-libzip';
	else
		PhpVersion='php-5.6.40';
	fi;

	echo "[OK] You Selected: ${selected}";
}

function InputDomain()
{
	if [ "$Domain" == '' ]; then
		Domain=`curl -s http://members.3322.org/dyndns/getip` && Domain=`echo $Domain | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`;
		#echo '[Error] empty server ip.';
		#read -p '[Notice] Please input server ip:' Domain;
		#[ "$Domain" == '' ] && InputDomain;
	fi;
	[ "$Domain" != '' ] && echo '[OK] Your server ip is:' && echo $Domain;
}


function InputMysqlPass()
{
	read -p '[Notice] Please input MySQL password:' MysqlPass;
	if [ "$MysqlPass" == '' ]; then
		echo '[Error] MySQL password is empty.';
		InputMysqlPass;
	else
		echo '[OK] Your MySQL password is:';
		echo $MysqlPass;
	fi;
}


function InputAMHPass()
{
	read -p '[Notice] Please input AMH password:' AMHPass;
	if [ "$AMHPass" == '' ]; then
		echo '[Error] AMH password empty.';
		InputAMHPass;
	else
		echo '[OK] Your AMH password is:';
		echo $AMHPass;
	fi;
}

function CloseSelinux()
{
	[ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
	setenforce 0 >/dev/null 2>&1;
}

function InstallBasePackages()
{
	rm -rf /etc/localtime;
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;

	if [ "$SysName" == 'CentOS' ]; then
		echo '[yum-fastestmirror Installing] ************************************************** >>';
		yum_repos_s=`ls /etc/yum.repos.d | wc -l`;
		if [ "$yum_repos_s" == '0' ]; then
			sed -i 's/^exclude/#exclude/' /etc/yum.conf;
			basearch_n='i386' && [ "$SysBit" == '64' ] && basearch_n='x86_64';
			cd /etc/yum.repos.d;
			wget http://code3.amh.sh/files/amh-redhat${Release}-base.repo -O amh-redhat${Release}-base.repo;
			sed -i "s#\$releasever#$Release#g" amh-redhat${Release}-base.repo;
			sed -i "s#\$basearch#$basearch_n#g" amh-redhat${Release}-base.repo;
			yum clean all;
			yum makecache;
		fi;
		yum -y remove httpd php mysql-server mysql php-mysql;
		yum -y install gcc gcc-c++ ncurses-devel libxml2-devel openssl-devel curl-devel libjpeg-devel libpng-devel autoconf pcre-devel libtool-libs freetype-devel gd zlib-devel zip unzip wget crontabs iptables file bison cmake patch mlocate flex diffutils automake make readline-devel  glibc-devel glibc-static glib2-devel bzip2-devel gettext-devel libcap-devel logrotate ftp openssl expect ntp vixie-cron;

	else
		apt-get remove -y nginx apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common php;
		killall apache2;
		apt-get -y update;
		apt-get -y install gcc g++ cmake make ntp ntpdate logrotate automake patch autoconf autoconf2.13 re2c wget flex cron libzip-dev libc6-dev rcconf bison cpp binutils unzip tar bzip2 libncurses5-dev libncurses5 libtool libevent-dev libpcre3 libpcre3-dev libpcrecpp0 libssl-dev zlibc openssl libsasl2-dev libxml2 libxml2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libfreetype6 libfreetype6-dev libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev curl libcurl3  libpq-dev libpq5 gettext libcurl4-gnutls-dev  libcurl4-openssl-dev libcap-dev ftp openssl expect;
	fi;

	ntpdate -u pool.ntp.org;
	StartDate=$(date);
	StartDateSecond=$(date +%s);
	echo "Start time: ${StartDate}";
}


function Downloadfile()
{
	randstr=$(date +%s);
	cd $AMHDir/packages;

	if [ -s $1 ]; then
		echo "[OK] $1 found.";
	else
		echo "[Notice] $1 not found, download now......";
		if ! wget -c --no-check-certificate --tries=3 ${2} ; then
			echo "[Error] Download Failed : $1, please check $2 ";
			exit;
		else
			mv ${1} $1;
		fi;
	fi;
}

function InstallReady()
{
	mkdir -p $AMHDir/conf;
	mkdir -p $AMHDir/packages/untar;
	chmod +Rw $AMHDir/packages;

	mkdir -p /root/amh/;
	chmod +Rw /root/amh;

	cd $AMHDir/packages;
	wget http://api.cccyun.cc/conf.zip -O conf.zip;
	unzip -o conf.zip -d $AMHDir/conf;
}


# Install Function  *********************************************************

function Uninstall()
{
	amh host list 2>/dev/null;
	echo -e "\033[41m\033[37m[Warning] Please backup your data first. Uninstall will delete all the data!!! \033[0m ";
	read -p '[Notice] Backup the data now? : (y/n)' confirmBD;
	[ "$confirmBD" != 'y' -a "$confirmBD" != 'n' ] && exit;
	[ "$confirmBD" == 'y' ] && amh backup;
	echo '=============================================================';

	read -p '[Notice] Confirm Uninstall(Delete All Data)? : (y/n)' confirmUN;
	[ "$confirmUN" != 'y' ] && exit;
	amh mysql stop 2>/dev/null;
	amh php stop 2>/dev/null;
	amh nginx stop 2>/dev/null;

	killall nginx;
	killall mysqld;
	killall pure-ftpd;
	killall php-cgi;
	killall php-fpm;

	[ "$SysName" == 'CentOS' ] && chkconfig amh-start off || update-rc.d -f amh-start remove;
	rm -rf /etc/init.d/amh-start;
	rm -rf /usr/local/libiconv;
	rm -rf /usr/local/nginx/ ;
	for line in `ls /root/amh/modules`; do
		amh module $line uninstall;
	done;
	rm -rf /usr/local/mysql/ /etc/my.cnf  /etc/ld.so.conf.d/mysql.conf /usr/bin/mysql /var/lock/subsys/mysql /var/spool/mail/mysql;
	rm -rf /usr/local/php/ /usr/lib/php /etc/php.ini /etc/php.d /usr/local/zend;
	rm -rf /home/wwwroot/;
	rm -rf /etc/pure-ftpd.conf /etc/pam.d/ftp /usr/local/sbin/pure-ftpd /etc/pureftpd.passwd /etc/amh-iptables;
	rm -rf /etc/logrotate.d/nginx /root/.mysqlroot;
	rm -rf /root/amh /bin/amh;
	rm -rf $AMHDir;
	rm -f /usr/bin/{mysqld_safe,myisamchk,mysqldump,mysqladmin,mysql,nginx,php-fpm,phpize,php};

	echo '[OK] Successfully uninstall AMH.';
	exit;
}

function InstallLibiconv()
{
	echo "[${LibiconvVersion} Installing] ************************************************** >>";
	Downloadfile "${LibiconvVersion}.tar.gz" "https://mirror.tuna.tsinghua.edu.cn/gnu/libiconv/${LibiconvVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$LibiconvVersion;
	echo "tar -zxf ${LibiconvVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$LibiconvVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/libiconv ]; then
		cd $AMHDir/packages/untar/$LibiconvVersion;
		./configure --prefix=/usr/local/libiconv;
		make;
		make install;
		echo "[OK] ${LibiconvVersion} install completed.";
	else
		echo '[OK] libiconv is installed!';
	fi;
}


function InstallMysql()
{
	# [dir] /usr/local/mysql/
	echo "[${MysqlVersion} Installing] ************************************************** >>";

	Downloadfile "${MysqlVersion}.tar.gz" "https://mirror.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.5/${MysqlVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$MysqlVersion;
	echo "tar -zxf ${MysqlVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$MysqlVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -f /usr/local/mysql/bin/mysql ]; then
		cd $AMHDir/packages/untar/$MysqlVersion;
		groupadd mysql;
		useradd -s /sbin/nologin -g mysql mysql;
		cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3306 -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1;
		#http://forge.mysql.com/wiki/Autotools_to_CMake_Transition_Guide
		make -j $Cpunum;
		make install;
		chmod +w /usr/local/mysql;
		chown -R mysql:mysql /usr/local/mysql;

		rm -f /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf;
		cp $AMHDir/conf/my.cnf /etc/my.cnf;
		cp $AMHDir/conf/mysql /root/amh/mysql;
		chmod +x /root/amh/mysql;
		/usr/local/mysql/scripts/mysql_install_db --user=mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data;


# EOF **********************************
cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib/mysql
/usr/local/lib
EOF
# **************************************

		ldconfig;
		if [ "$SysBit" == '64' ] ; then
			ln -s /usr/local/mysql/lib/mysql /usr/lib64/mysql;
		else
			ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql;
		fi;
		chmod 775 /usr/local/mysql/support-files/mysql.server;
		/usr/local/mysql/support-files/mysql.server start;
		ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql;
		ln -s /usr/local/mysql/bin/mysqladmin /usr/bin/mysqladmin;
		ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump;
		ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk;
		ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe;

		/usr/local/mysql/bin/mysqladmin password $MysqlPass;
		rm -rf /usr/local/mysql/data/test;

# EOF **********************************
mysql -hlocalhost -uroot -p$MysqlPass <<EOF
USE mysql;
DELETE FROM user WHERE User!='root' OR (User = 'root' AND Host != 'localhost');
UPDATE user set password=password('$MysqlPass') WHERE User='root';
DROP USER ''@'%';
FLUSH PRIVILEGES;
EOF
# **************************************
		echo "[OK] ${MysqlVersion} install completed.";
	else
		echo '[OK] MySQL is installed.';
	fi;

}

function InstallPhp()
{
	# [dir] /usr/local/php
	echo "[${PhpVersion} Installing] ************************************************** >>";
	Downloadfile "${PhpVersion}.tar.gz" "http://mirrors.sohu.com/php/${PhpVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$PhpVersion;
	echo "tar -zxf ${PhpVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$PhpVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/php ]; then
		cd $AMHDir/packages/untar/$PhpVersion;
		groupadd www;
		useradd -m -s /sbin/nologin -g www www;
		if [ "$InstallModel" == '1' ]; then
			./configure --prefix=/usr/local/php --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-openssl-dir=/usr/lib/openssl --with-openssl --with-zlib --with-curl --enable-ftp --enable-opcache --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-sockets --enable-sockets --with-iconv=/usr/local/libiconv --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql/bin/mysql_config --without-pear $PHPDisable;
		fi;
		make -j $Cpunum;
		make install;

		cp $AMHDir/conf/php.ini /etc/php.ini;
		cp $AMHDir/conf/php /root/amh/php;
		cp $AMHDir/conf/php-fpm.conf /usr/local/php/etc/php-fpm.conf;
		cp $AMHDir/conf/php-fpm-template.conf /usr/local/php/etc/php-fpm-template.conf;
		chmod +x /root/amh/php;
		mkdir /etc/php.d;
		mkdir /usr/local/php/etc/fpm;
		mkdir /usr/local/php/var/run/pid;
		touch /usr/local/php/etc/fpm/amh.conf;
		/usr/local/php/sbin/php-fpm;

		ln -s /usr/local/php/bin/php /usr/bin/php;
		ln -s /usr/local/php/bin/phpize /usr/bin/phpize;
		ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm;

		echo "[OK] ${PhpVersion} install completed.";
	else
		echo '[OK] PHP is installed.';
	fi;
}

function InstallNginx()
{
	# [dir] /usr/local/nginx
	echo "[${NginxVersion} Installing] ************************************************** >>";
	Downloadfile "${NginxVersion}.tar.gz" "http://tengine.taobao.org/download/${NginxVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$NginxVersion;
	echo "tar -zxf ${NginxVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$NginxVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/nginx ]; then
		cd $AMHDir/packages/untar/$NginxVersion;
		./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_v2_module --with-threads --with-http_gzip_static_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_uwsgi_module --without-http_scgi_module ;
		make -j $Cpunum;
		make install;

		mkdir -p /home/wwwroot/index /home/backup /usr/local/nginx/conf/vhost/  /usr/local/nginx/conf/vhost_stop/  /usr/local/nginx/conf/rewrite/;
		chown +w /home/wwwroot/index;
		touch /usr/local/nginx/conf/rewrite/amh.conf;

		cp $AMHDir/conf/nginx.conf /usr/local/nginx/conf/nginx.conf;
		cp $AMHDir/conf/nginx-host.conf /usr/local/nginx/conf/nginx-host.conf;
		cp $AMHDir/conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf;
		cp $AMHDir/conf/fcgi-host.conf /usr/local/nginx/conf/fcgi-host.conf;
		cp $AMHDir/conf/nginx /root/amh/nginx;
		cp $AMHDir/conf/host /root/amh/host;
		chmod +x /root/amh/nginx;
		chmod +x /root/amh/host;
		sed -i 's/www.amysql.com/'$Domain'/g' /usr/local/nginx/conf/nginx.conf;

		cd /home/wwwroot/index;
		mkdir -p tmp etc/rsa bin usr/sbin log;
		touch etc/upgrade.conf;
		chown mysql:mysql etc/rsa;
		chmod 777 tmp;
		[ "$SysBit" == '64' ] && mkdir lib64 || mkdir lib;
		/usr/local/nginx/sbin/nginx;
		/usr/local/php/sbin/php-fpm;
		ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx;

		echo "[OK] ${NginxVersion} install completed.";
	else
		echo '[OK] Nginx is installed.';
	fi;
}

function InstallPureFTPd()
{
	# [dir] /etc/	/usr/local/bin	/usr/local/sbin
	echo "[${PureFTPdVersion} Installing] ************************************************** >>";
	Downloadfile "${PureFTPdVersion}.tar.gz" "http://download.cdnbest.com/easypanel/source/${PureFTPdVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$PureFTPdVersion;
	echo "tar -zxf ${PureFTPdVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$PureFTPdVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -f /etc/pure-ftpd.conf ]; then
		cd $AMHDir/packages/untar/$PureFTPdVersion;
		./configure --with-puredb --with-quotas --with-throttling --with-ratios --with-peruserlimits;
		make -j $Cpunum;
		make install;
		cp contrib/redhat.init /usr/local/sbin/redhat.init;
		chmod 755 /usr/local/sbin/redhat.init;

		cp $AMHDir/conf/pure-ftpd.conf /etc;
		cp configuration-file/pure-config.pl /usr/local/sbin/pure-config.pl;
		chmod 744 /etc/pure-ftpd.conf;
		chmod 755 /usr/local/sbin/pure-config.pl;
		/usr/local/sbin/redhat.init start;

		groupadd ftpgroup;
		useradd -d /home/wwwroot/ -s /sbin/nologin -g ftpgroup ftpuser;

		cp $AMHDir/conf/ftp /root/amh/ftp;
		chmod +x /root/amh/ftp;

		/sbin/iptables-save > /etc/amh-iptables;
		sed -i '/--dport 21 -j ACCEPT/d' /etc/amh-iptables;
		sed -i '/--dport 80 -j ACCEPT/d' /etc/amh-iptables;
		sed -i '/--dport 443 -j ACCEPT/d' /etc/amh-iptables;
		sed -i '/--dport 8888 -j ACCEPT/d' /etc/amh-iptables;
		sed -i '/--dport 10100:10110 -j ACCEPT/d' /etc/amh-iptables;
		/sbin/iptables-restore < /etc/amh-iptables;
		/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT;
		/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT;
		/sbin/iptables -I INPUT -p tcp --dport 443 -j ACCEPT;
		/sbin/iptables -I INPUT -p tcp --dport 8888 -j ACCEPT;
		/sbin/iptables -I INPUT -p tcp --dport 10100:10110 -j ACCEPT;
		/sbin/iptables-save > /etc/amh-iptables;
		echo 'IPTABLES_MODULES="ip_conntrack_ftp"' >>/etc/sysconfig/iptables-config;

		touch /etc/pureftpd.passwd;
		chmod 774 /etc/pureftpd.passwd;
		echo "[OK] ${PureFTPdVersion} install completed.";
	else
		echo '[OK] PureFTPd is installed.';
	fi;
}

function InstallAMH()
{
	# [dir] /home/wwwroot/index/web
	echo "[${AMHVersion} Installing] ************************************************** >>";
	Downloadfile "${AMHVersion}.tar.gz" "http://api.cccyun.cc/${AMHVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$AMHVersion;
	echo "tar -xf ${AMHVersion}.tar.gz ing...";
	tar -xf $AMHDir/packages/$AMHVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /home/wwwroot/index/web ]; then
		cp -r $AMHDir/packages/untar/$AMHVersion /home/wwwroot/index/web;

		gcc -o /bin/amh -Wall $AMHDir/conf/amh.c;
		chmod 4775 /bin/amh;
		cp -a $AMHDir/conf/amh-backup.conf /home/wwwroot/index/etc;
		cp -a $AMHDir/conf/html /home/wwwroot/index/etc;
		cp $AMHDir/conf/{backup,revert,BRssh,BRftp,info,SetParam,module,crontab,upgrade} /root/amh;
		cp -a $AMHDir/conf/modules /root/amh;
		chmod +x /root/amh/backup /root/amh/revert /root/amh/BRssh /root/amh/BRftp /root/amh/info /root/amh/SetParam /root/amh/module /root/amh/crontab /root/amh/upgrade;

		SedMysqlPass=${MysqlPass//&/\\\&};
		SedMysqlPass=${SedMysqlPass//\'/\\\\\'};
		sed -i "s/'MysqlPass'/'${SedMysqlPass}'/g" /home/wwwroot/index/web/Amysql/Config.php;
		chown www:www /home/wwwroot/index/web/Amysql/Config.php;

		SedAMHPass=${AMHPass//&/\\\&};
		SedAMHPass=${SedAMHPass//\'/\\\\\\\\\'\'};
		sed -i "s/'AMHPass_amysql-amh'/'${SedAMHPass}_amysql-amh'/g" $AMHDir/conf/amh.sql;
		/usr/local/mysql/bin/mysql -u root -p$MysqlPass < $AMHDir/conf/amh.sql;

		echo "[OK] ${AMHVersion} install completed.";
	else
		echo '[OK] AMH is installed.';
	fi;
}

function InstallAMS()
{
	# [dir] /home/wwwroot/index/web/ams
	echo "[${AMSVersion} Installing] ************************************************** >>";
	Downloadfile "${AMSVersion}.tar.gz" "http://api.cccyun.cc/${AMSVersion}.tar.gz";
	rm -rf $AMHDir/packages/untar/$AMSVersion;
	echo "tar -xf ${AMSVersion}.tar.gz ing...";
	tar -xf $AMHDir/packages/$AMSVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /home/wwwroot/index/web/ams ]; then
		cp -r $AMHDir/packages/untar/$AMSVersion /home/wwwroot/index/web/ams;
		chown www:www -R /home/wwwroot/index/web/ams/View/DataFile;
		echo "[OK] ${AMSVersion} install completed.";
	else
		echo '[OK] AMS is installed.';
	fi;
}


# AMH Installing ****************************************************************************
CheckSystem;
ConfirmInstall;
InputDomain;
InputMysqlPass;
InputAMHPass;
SelectPHP;
CloseSelinux;
InstallBasePackages;
InstallReady;
InstallLibiconv;
InstallMysql;
InstallPhp;
InstallNginx;
InstallPureFTPd;
InstallAMH;
InstallAMS;


if [ -s /usr/local/nginx ] && [ -s /usr/local/php ] && [ -s /usr/local/mysql ]; then

cp $AMHDir/conf/amh-start /etc/init.d/amh-start;
chmod 775 /etc/init.d/amh-start;
if [ "$SysName" == 'CentOS' ]; then
	chkconfig --add amh-start;
	chkconfig amh-start on;
else
	update-rc.d -f amh-start defaults;
fi;

/etc/init.d/amh-start;
rm -rf $AMHDir;

echo '================================================================';
	echo '[AMH] Congratulations, AMH 4.2 install completed.';
	echo "AMH Management: http://${Domain}:8888";
	echo 'User:admin';
	echo "Password:${AMHPass}";
	echo "MySQL Password:${MysqlPass}";
	echo '';
	echo '******* SSH Management *******';
	echo 'Host: amh host';
	echo 'PHP: amh php';
	echo 'Nginx: amh nginx';
	echo 'MySQL: amh mysql';
	echo 'FTP: amh ftp';
	echo 'Backup: amh backup';
	echo 'Revert: amh revert';
	echo 'SetParam: amh SetParam';
	echo 'Module : amh module';
	echo 'Crontab : amh crontab';
	echo 'Upgrade : amh upgrade';
	echo 'Info: amh info';
	echo '';
	echo '******* SSH Dirs *******';
	echo 'WebSite: /home/wwwroot';
	echo 'Nginx: /usr/local/nginx';
	echo 'PHP: /usr/local/php';
	echo 'MySQL: /usr/local/mysql';
	echo 'MySQL-Data: /usr/local/mysql/data';
	echo '';
	echo "Start time: ${StartDate}";
	echo "Completion time: $(date) (Use: $[($(date +%s)-StartDateSecond)/60] minute)";
	echo 'More help please visit:http://amysql.com';
echo '================================================================';
else
	echo 'Sorry, Failed to install AMH';
	echo 'Please contact us: http://amysql.com';
fi;
