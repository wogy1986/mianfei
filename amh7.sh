#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear;
echo '================================================================';
echo ' [LNMP/Nginx] Amysql Host - AMH 4.2 (Sxsay.Com mod v45)';
echo ' http://Amysql.com';
echo ' https://www.sxsay.com';
echo 'Memory less than 1GB, can't install MySQL 5.7 or MairaDB 10!'';
echo '================================================================';


# VAR ***************************************************************************************
AMHDir='/home/amh_install';
SysName='';
Inst='';
Is_ARM='';
SysBit='';
Cpunum='';
RamTotal='';
RamSwap='';
InstallModel='';
confirm='';
Domain=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168\.1|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`;
#Domain='';
Gccver='';
Codename='';
MysqlPass='';
AMHPass='';
StartDate='';
StartDateSecond='';
PHPDisable='';
ImapPath='';
DISTRO='';
RHEL_Ver='';
Ser='';
ins='/root';
NVersion='';
ConfirmDomain='';
localhost='';
# Version
Amver='amh4.5';
confver="conf"
AMHcurl="curl-7.53.0"
AMSVersion='ams-1.5.0107-02';
AMHVersion='amh-4.5';
LibiconvVersion='libiconv-1.15';
Mysql55Version='mysql-5.5.54';
Mysql56Version='mysql-5.6.35';
Mysql57Version='mysql-5.7.17';
Mariadb55Version='mariadb-5.5.54';
Mariadb10Version='mariadb-10.1.21';
Php53Version='php-5.3.29';
Php54Version='php-5.4.45';
Php55Version='php-5.5.38';
Php56Version='php-5.6.30';
Php70Version='php-7.0.17';
Php71Version='php-7.1.3';
NginxVersion='nginx-1.10.3';
TengineVersion='tengine-2.2.0';
OpenSSLVersion='openssl-1.1.0e';
NginxCachePurgeVersion='ngx_cache_purge-2.3';
EchoNginxVersion='echo-nginx-module-0.58';
NgxHttpSubstitutionsFilter='ngx_http_substitutions_filter_module-0.6.4';
PureFTPdVersion='pure-ftpd-1.0.36';
LibMcryptVersion='libmcrypt-2.5.8';
McyptVersion='mcrypt-2.6.8';
MashVersion='mhash-0.9.9.9';
MashVersion='mhash-0.9.9.9';
IampVersion='imap-2007f';
Boost_Ver='boost_1_59_0';
Libicu4c_Ver='icu4c-55_1'
Freetype_Ver='freetype-2.4.12'
# Function List	*****************************************************************************
function CheckSystem()
{
	[ $(id -u) != '0' ] && echo '[Error] Please use root to install AMH.' && exit;
	if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
	  SysName='centos';
	  Inst='yum';
	elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
	  SysName='RHEL';
	  Inst='yum';
	elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
	  SysName='Aliyun';
	  Inst='yum';
	elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
      SysName='Fedora';
      Inst='yum';
	elif grep -Eqi "Amazon Linux AMI" /etc/issue || grep -Eq "Amazon Linux AMI" /etc/*-release; then
      SysName='Amazon';
      Inst='yum';
	elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
      SysName='debian';
	  Inst='apt';
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
      SysName='Ubuntu';
      Inst='apt';
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
      SysName='Raspbian'
      Inst='apt';
	elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
      SysName='Deepin';
      Inst='apt';
	else
      SysName='unknow';
    fi;
    if uname -m | grep -Eqi "arm"; then
     Is_ARM='arm';
		else
	 Is_ARM=`uname -m`;
    fi;
	[ "$SysName" == ''  ] && echo '[Error] Your system is not supported install AMH' && exit;
	[ "$SysName" == 'unknow'  ] && echo '[Error] Your system is not supported install AMH' && exit;
	SysBit='32' && [ `getconf WORD_BIT` == '32' ] && [ `getconf LONG_BIT` == '64' ] && SysBit='64';
	Cpunum=`cat /proc/cpuinfo | grep 'processor' | wc -l`;
	RamTotal=`free -m | grep 'Mem' | awk '{print $2}'`;
	RamSwap=`free -m | grep 'Swap' | awk '{print $2}'`;
	echo "Server ${Domain}";
	echo "${SysBit}Bit, ${Cpunum}*CPU, ${RamTotal}MB*RAM, ${RamSwap}MB*Swap";
	echo "${Is_ARM}, Instruction ";
	echo '================================================================';
	
	RamSum=$[$RamTotal+$RamSwap];
	[ "$SysBit" == '32' ] && [ "$RamSum" -lt '250' ] && \
	echo -e "[Error] Not enough memory install AMH. \n(32bit system need memory: ${RamTotal}MB*RAM + ${RamSwap}MB*Swap > 250MB)" && exit;

	if [ "$SysBit" == '64' ] && [ "$RamSum" -lt '480' ];  then
		echo -e "[Error] Not enough memory install AMH. \n(64bit system need memory: ${RamTotal}MB*RAM + ${RamSwap}MB*Swap > 480MB)";
		[ "$RamSum" -gt '250' ] && echo "[Notice] Please use 32bit system.";
		exit;
	fi;
	
	[ "$RamSum" -lt '600' ] && PHPDisable='--disable-fileinfo';
}

function RHELVersion()
{
    if [ "${SysName}" = "RHEL" ]; then
        if grep -Eqi "release 5." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 5";
            RHEL_Ver='5';
        elif grep -Eqi "release 6." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 6";
            RHEL_Ver='6';
        elif grep -Eqi "release 7." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 7";
            RHEL_Ver='7';
	       if [ "$SysName"=='centos' ]; then
            if [ "$RHEL_Ver"=='7' ]; then
   	         yum install -y net-tools.x86_64;
			 fi;
	   fi;
        fi;
    fi;
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
	
		#选择安装nginx 或者 tengine
	echo "[Notice] Confirm Install Nginx(${NginxVersion})/Tengine(${TengineVersion})? please select: (1~3)"
	select selected in 'Nginx' 'Tengine' 'Exit'; do break; done;
	[ "$selected" == 'Exit' ] && echo 'Exit Install.' && exit;
		
	if [ "$selected" == 'Nginx' ]; then
		NginxVersion=$NginxVersion;
	    NVersion="Nginx" && echo "[OK] ${NginxVersion} installed";
	elif [ "$selected" == 'Tengine' ]; then
		NginxVersion=$TengineVersion;
		 NVersion="Tengine" &&  echo "[OK] ${TengineVersion} installed";
	else
		ConfirmInstall;
		return;
	fi;
	
    echo "[Notice] Select Server Area : (1~2)"
	select Serselect in 'localhost' 'Sxsay.com' 'Exit'; do break; done;
	[ "$serselect" == 'Exit' ] && echo 'Exit Install.' && exit;
		
	if [ "$Serselect" == 'localhost' ]; then
	Ser='localhost' && echo '[OK] localhost installed';
	elif [ "$Serselect" == 'Sxsay.com' ]; then
	Ser='http://www.sxsay.com/amh' && echo '[OK] Sxsay.com installed';
	else
		ConfirmInstall;
		return;
	fi;
	echo "[OK] You Selected: ${Serselect}";
	
	echo "[Notice] Confirm Install Mysql / Mariadb? please select: (1~6)"
	select DBselect in 'Mysql-5.5.54' 'Mysql-5.6.35' 'Mysql-5.7.17' 'Mariadb-5.5.54' 'Mariadb-10.1.21' 'Exit'; do break; done;
	[ "$DBselect" == 'Exit' ] && echo 'Exit Install.' && exit;
		
	if [ "$DBselect" == 'Mysql-5.5.54' ]; then
	confirm='1' && echo '[OK] Mysql-5.5.54 installed';
	elif [ "$DBselect" == 'Mysql-5.6.35' ]; then
	confirm='2' && echo '[OK] Mysql-5.6.35 installed';
	elif [ "$DBselect" == 'Mysql-5.7.17' ]; then
	confirm='3' && echo '[OK] Mysql-5.7.17 installed';
	elif [ "$DBselect" == 'Mariadb-5.5.54' ]; then
	confirm='4' && echo '[OK] Mariadb-5.5.54 installed';
	elif [ "$DBselect" == 'Mariadb-10.1.21' ]; then
	confirm='5' && echo '[OK] Mariadb-10.1.21 installed';
	else
		ConfirmInstall;
		return;
	fi;
	
	echo "[OK] You Selected: ${DBselect}";
	
	read -p '[Notice] Do you want PHP5.3? : (y/n)' confirm53;
	[ "$confirm53" == 'y' ] && echo '[OK] php5.3 will be installed';
	read -p '[Notice] Do you want PHP5.4? : (y/n)' confirm54;
	[ "$confirm54" == 'y' ] && echo '[OK] php5.4 will be installed';
	read -p '[Notice] Do you want PHP5.5? : (y/n)' confirm55;
	[ "$confirm55" == 'y' ] && echo '[OK] php5.5 will be installed';
	read -p '[Notice] Do you want PHP7.0? : (y/n)' confirm70;
	[ "$confirm70" == 'y' ] && echo '[OK] php7.0 will be installed';
	read -p '[Notice] Do you want PHP7.1? : (y/n)' confirm71;
	[ "$confirm70" == 'y' ] && echo '[OK] php7.1 will be installed';		
}

function InputDomain()
{
   if [ "$SysName"=='centos' ]; then
    if [ "$RHEL_Ver"=='7' ]; then
   	  #Domain='';
	 #Domain=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168\.1|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1`;
	 Domain=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168\.1|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`;
	 	 else
	 Domain=`ifconfig  | grep 'inet addr:'| egrep -v ":192.168|:172.1[6-9].|:172.2[0-9].|:172.3[0-2].|:10\.|:127." | cut -d: -f2 | awk '{ print $1}'`;
	 fi;
	if [ "$Domain" == '' ]; then
        echo '[Error] empty server ip.';
		read -p '[Notice] Please input server ip:' Domain;
		[ "$Domain" == '' ] && InputDomain;
		else
		echo 'Your server ip is:' && echo $Domain;
	fi;
	fi;
	read -p '[Notice] Please make sure that IP is correct? : (y/n)' ConfirmDomain;
	[ "$ConfirmDomain" == 'y' ] && echo '[OK] Domain IP correct';
	if [ "$ConfirmDomain" == 'y' ]; then
	echo '[OK] Your server ip is:' && echo $Domain;
	else
	read -p '[Notice] Please input server ip:' Domain;
	echo '[OK] Your server ip is:' && echo $Domain;
	fi;
	#[ "$Domain" != '' ] && echo '[OK] Your server ip is:' && echo $Domain;
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


function Timezone()
{
	rm -rf /etc/localtime;
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;

	echo '[ntp Installing] ******************************** >>';
	[ "$Inst" == 'yum' ] && yum install -y ntp || apt-get install -y ntpdate;
	ntpdate -u pool.ntp.org;
	StartDate=$(date);
	StartDateSecond=$(date +%s);
	echo "Start time: ${StartDate}";
}

Remove_Error_Libcurl()
{
    if [ -s /usr/local/lib/libcurl.so ]; then
        rm -f /usr/local/lib/libcurl*;
    fi;
}

function CloseSelinux()
{
	[ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
}

function DeletePackages()
{
	if [ "$Inst" == 'yum' ]; then
        rpm -qa|grep httpd;
        rpm -e httpd httpd-tools --nodeps;
        rpm -qa|grep mysql;
        rpm -e mysql mysql-libs --nodeps;
        rpm -qa|grep php;
        rpm -e php-mysql php-cli php-gd php-common php --nodeps;
		Remove_Error_Libcurl;

        yum -y remove httpd*;
        yum -y remove mysql-server mysql mysql-libs;
        yum -y remove php*;
		yum -y remove php-mysql;
        yum clean all;
	else
		apt-get --purge remove nginx
		apt-get --purge remove mysql-server;
		apt-get --purge remove mysql-common;
		apt-get --purge remove php;
		killall apache2;
		dpkg -l |grep apache;
        dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common;
        dpkg -l |grep mysql;
        dpkg -P mysql-server mysql-common libmysqlclient15off libmysqlclient15-dev;
        dpkg -l |grep php;
        dpkg -P php5 php5-common php5-cli php5-cgi php5-mysql php5-curl php5-gd;
        apt-get autoremove -y && apt-get clean;
	fi;
}

function InstallBasePackages()
{
   if [ "$SysName"=='debian' ]; then
   mv /etc/apt/sources.list /etc/apt/sources.list.bak;
   cd /etc/apt;
   wget http://www.sxsay.com/amh/sources.list;
   apt-get update;
   	else
   echo '[No Wget] System No is Debian.';
   fi;
	 if [ "$Inst" == 'yum' ]; then
		echo '[yum-fastestmirror Installing] ************************************************** >>';
		yum -y install yum-fastestmirror;

		cp /etc/yum.conf /etc/yum.conf.lnmp
		sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
		for packages in make cmake gcc gcc-c++ gcc-g77 libcap icu libtiff-devel libicu libicu-devel libjpeg gettext gettext-devel libidn libidn-devel libxslt krb5 libxslt-devel ncurses-devel libXpm-devel libxml2-devel openssl-devel libjpeg-devel pspell-devel libpng libpng-devel pam-devel libevent-devel libc-client-devel autoconf pcre-devel libtool-libs freetype-devel gd zlib-devel zip unzip wget crontabs iptables file bison cmake patch mlocate flex diffutils automake make  readline-devel  glibc-devel glibc-static glib2 glib2-devel  bzip2-devel libcap-devel logrotate ftp openssl expect; do 
			echo "[${packages} Installing] ************************************************** >>";
			yum -y install $packages; 
		done;
		mv -f /etc/yum.conf.lnmp /etc/yum.conf;
	else
		apt-get remove -y apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd;
		apt-get update -y;

		for packages in build-essential gcc g++ icu libicu libicu-devel libxslt less psmisc libxslt libxslt1-dev cpp libxslt1-dev cmake make ntp logrotate automake m4 gawk libevent-devel patch autoconf autoconf2.13 re2c wget flex cron libpam0g-dev libreadline5-dev libreadline-gplv2-dev libc-client-dev libzip-dev libc6-dev rcconf bison cpp binutils unzip tar bzip2 libncurses5-dev libncurses5 libtool libevent-dev libpcre3 libpcre3-dev libpcrecpp0 libssl-dev zlibc libsasl2-dev libxml2 libxml2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libfreetype6 libfreetype6-dev libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev libcurl3  libpq-dev libpq5 libkrb5-dev gettext libcurl4-gnutls-dev  libcurl4-openssl-dev libcap-dev ftp openssl expect; do
			echo "[${packages} Installing] ************************************************** >>";
			apt-get install -y $packages --force-yes;apt-get -fy install;apt-get -y autoremove;		
		done;
	
	  fi;
	  if [ "${SysName}" = "Ubuntu" ]; then
        Ubuntu_Modify_Source;
    fi;
	Gccver=`gcc -dumpversion --version`;
    Timezone;
	Download;
}
Ubuntu_Modify_Source()
{
    CodeName='';
    if grep -Eqi "10.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.10'; then
        CodeName='maverick';
    elif grep -Eqi "11.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.04'; then
        CodeName='natty';
    elif  grep -Eqi "11.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.10'; then
        CodeName='oneiric';
    elif grep -Eqi "12.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.10'; then
        CodeName='quantal';
    elif grep -Eqi "13.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.04'; then
        CodeName='raring';
    elif grep -Eqi "13.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.10'; then
        CodeName='saucy';
    elif grep -Eqi "10.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.04'; then
        CodeName='lucid';
    elif grep -Eqi "14.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.10'; then
        Ubuntu_Deadline utopic;
    elif grep -Eqi "15.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.04'; then
        Ubuntu_Deadline vivid;
    elif grep -Eqi "12.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.04'; then
        Ubuntu_Deadline precise;
    elif grep -Eqi "15.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.10'; then
        Ubuntu_Deadline wily;
    fi;
    if [ "${CodeName}" != "" ]; then
        \cp /etc/apt/sources.list /etc/apt/sources.list.$(date +"%Y%m%d")
        cat > /etc/apt/sources.list<<EOF
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName} main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-security main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-updates main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-proposed main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-backports main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName} main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-security main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-updates main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-proposed main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-backports main restricted universe multiverse
EOF
    fi;
}

Ubuntu_Deadline()
{
    utopic_deadline=`date -d "2015-10-1 00:00:00" +%s`
    vivid_deadline=`date -d "2016-2-24 00:00:00" +%s`
    precise_deadline=`date -d "2017-5-27 00:00:00" +%s`
    wily_deadline=`date -d "2016-7-22 00:00:00" +%s`
    cur_time=`date  +%s`
    case "$1" in
        utopic)
            if [ ${cur_time} -gt ${utopic_deadline} ]; then
                echo "${cur_time} > ${utopic_deadline}"
                Check_Old_Releases_URL utopic
            fi
            ;;
        vivid)
            if [ ${cur_time} -gt ${vivid_deadline} ]; then
                echo "${cur_time} > ${vivid_deadline}"
                Check_Old_Releases_URL vivid
            fi
            ;;
        precise)
            if [ ${cur_time} -gt ${precise_deadline} ]; then
                echo "${cur_time} > ${precise_deadline}"
                Check_Old_Releases_URL precise
            fi
            ;;
        wily)
            if [ ${cur_time} -gt ${wily_deadline} ]; then
                echo "${cur_time} > ${wily_deadline}"
                Check_Old_Releases_URL wily
            fi
            ;;
    esac
}

function Download()
{
   echo "[+] Downloading files...";
   if [ "$Ser"  == 'localhost' ]; then
    if [ ! -e $ins/$Amver.tar.gz ]; then
	cd /root;
	wget $Ser/$Amver.tar.gz;
	if [ ! -e $ins/$Amver.tar.gz ]; then
	echo '[Error] AMH-V4.5 is empty.' && exit;
	fi;
   tar -zxf /root/$Amver.tar.gz -C /home;
   fi;
  else
   mkdir -p /home/amh_install;
   mkdir -p /home/amh_install/packages;
   mkdir -p /home/amh_install/packages/untar;
   mkdir -p /home/amh_install/packages/untar/$confver;
   chmod +Rw /home/amh_install/packages;
   cd /home/amh_install/packages;
   Downloadfile "${AMHcurl}.tar.gz" " ${Ser}/${AMHcurl}.tar.gz";
   Downloadfile "${confver}.zip" "${Ser}/${confver}.zip";
   Downloadfile "${LibiconvVersion}.tar.gz" "${Ser}/${LibiconvVersion}.tar.gz";
   Downloadfile "${LibMcryptVersion}.tar.gz" "${Ser}/${LibMcryptVersion}.tar.gz";
   Downloadfile "${MashVersion}.tar.gz" "${Ser}/${MashVersion}.tar.gz";
   Downloadfile "${McyptVersion}.tar.gz" "${Ser}/${McyptVersion}.tar.gz";
   Downloadfile "${IampVersion}.tar.gz" "${Ser}/${IampVersion}.tar.gz";
   Downloadfile "${OpenSSLVersion}.tar.gz" "${Ser}/${OpenSSLVersion}.tar.gz";
   Downloadfile "${Php56Version}.tar.gz" "${Ser}/${Php56Version}.tar.gz";
   Downloadfile "${NginxVersion}.tar.gz" "${Ser}/${NginxVersion}.tar.gz";
   Downloadfile "${NginxCachePurgeVersion}.tar.gz" "${Ser}/${NginxCachePurgeVersion}.tar.gz";
   Downloadfile "${EchoNginxVersion}.tar.gz" "${Ser}/${EchoNginxVersion}.tar.gz";
   Downloadfile "${NgxHttpSubstitutionsFilter}.tar.gz" "${Ser}/${NgxHttpSubstitutionsFilter}.tar.gz";
   Downloadfile "${PureFTPdVersion}.tar.gz" "${Ser}/${PureFTPdVersion}.tar.gz";
   Downloadfile "${AMHVersion}.tar.gz" "${Ser}/${AMHVersion}.tar.gz";
   Downloadfile "${AMSVersion}.tar.gz" "${Ser}/${AMSVersion}.tar.gz";
   if [ "${Inst}" = 'apt' ]; then
   Downloadfile "${Libicu4c_Ver}"-src.tgz "${Ser}/${Libicu4c_Ver}-src.tgz";
   fi;
   if [ "${NVersion}" = 'Tengine' ]; then
   Downloadfile "openssl-1.0.2e.tar.gz" "${Ser}/openssl-1.0.2e.tar.gz";
   fi;
   if [ "$confirm"  == '1' ]; then
   Downloadfile "${Mysql55Version}.tar.gz" "${Ser}/${Mysql55Version}.tar.gz";
   fi;
   if [ "$confirm"  == '2' ]; then
   Downloadfile "${Mysql56Version}.tar.gz" "${Ser}/${Mysql56Version}.tar.gz";
   if [ "$confirm"  == '3' ]; then
   Downloadfile "${Boost_Ver}.tar.gz" "${Ser}/${Boost_Ver}.tar.gz";
   fi;
   Downloadfile "${Mysql57Version}.tar.gz" "${Ser}/${Mysql57Version}.tar.gz";
   if [ "$confirm"  == '4' ]; then
   Downloadfile "${Mariadb55Version}.tar.gz" "${Ser}/${Mariadb55Version}.tar.gz";
   fi;
   if [ "$confirm"  == '5' ]; then
   Downloadfile "${Mariadb10Version}.tar.gz" "${Ser}/${Mariadb10Version}.tar.gz";
   fi;
   if [ "$confirm53" == 'y' ]; then
   Downloadfile "${Php53Version}.tar.gz" "${Ser}/${Php53Version}.tar.gz";
   fi;
   if [ "$confirm54" == 'y' ]; then
   Downloadfile "${Php54Version}.tar.gz" "${Ser}/${Php54Version}.tar.gz";
   fi;
   if [ "$confirm55" == 'y' ]; then
   Downloadfile "${Php55Version}.tar.gz" "${Ser}/${Php55Version}.tar.gz";
   fi;
   if [ "$confirm70" == 'y' ]; then
   Downloadfile "${Php70Version}.tar.gz" "${Ser}/${Php70Version}.tar.gz";
   fi;
   if [ "$confirm71" == 'y' ]; then
   Downloadfile "${Php71Version}.tar.gz" "${Ser}/${Php71Version}.tar.gz";
   fi;
   fi;
   fi;
   cd /root;
   echo "[OK] Download Done completed.";
}
function Downloadfile()
{
	if [ "$Ser"  == 'localhost' ]; then
	localhost='${AMHDir}/packages';
	else
	cd /home/amh_install/packages;
	randstr=$(date +%s);
	if [ -s $1 ]; then
		echo "[OK] $1 found.";
	else
		echo "[Notice] $1 not found, download now......";
		if ! wget -c --tries=3 ${2}?${randstr} ; then
			echo "[Error] Download Failed : $1, please check $2 ";
			exit;
		else
			mv ${1}?${randstr} $1;
		fi;
	fi;
	fi;
	cd /root;
}

function InstallReady()
{
	mkdir -p $AMHDir/packages/untar/$confver;
	mkdir -p $AMHDir/packages/untar;
	chmod +Rw $AMHDir/packages;

	mkdir -p /root/amh/;
	chmod +Rw /root/amh;

	cd $AMHDir/packages;
	if [ ! -e $AMHDir/packages/$confver.zip ]; then
	Downloadfile "${confver}.zip" "${Ser}/${confver}.zip";
	fi;
	unzip $AMHDir/packages/$confver.zip -d $AMHDir/packages/untar/$confver;
}

function Installcurl()
{
if [ "$Inst" == 'yum' ]; then
   echo "[${Installcurl} Installing] ************************************************** >>";
   yum -y install gcc gcc-c++;
   cd $AMHDir/packages;
   if [ ! -e $AMHDir/packages/$AMHcurl.tar.gz ]; then
   Downloadfile "${AMHcurl}.tar.gz" " ${Ser}/${AMHcurl}.tar.gz";
   fi;
   tar -zxf $AMHDir/packages/$AMHcurl.tar.gz -C $AMHDir/packages/untar;
   cd $AMHDir/packages/untar/$AMHcurl;
   ./configure --prefix=/usr/local/curl;
   make -j $Cpunum;
   make install;
   cd /root;
 else
   echo "[${Installcurl} Installing] ************************************************** >>";
   apt-get install -y gcc g++ cmake make;
   if [ ! -e $AMHDir/packages/$AMHcurl.tar.gz ]; then
   Downloadfile "${AMHcurl}.tar.gz" " ${Ser}/${AMHcurl}.tar.gz";
   fi;
   tar -zxf $AMHDir/packages/$AMHcurl.tar.gz -C $AMHDir/packages/untar;
   cd $AMHDir/packages/untar/$AMHcurl;
   ./configure --prefix=/usr/local/curl;
    make -j $Cpunum;
    make install;
    #rm -rf $AMHDir/packages/untar/$AMHcurl.tar.gz;
	#rm -rf $AMHDir/packages/untar/$AMHcurl;
 fi;
}

function InstallIcu4c()
{
        echo "[+] Installing ${Libicu4c_Ver}";
		if [ ! -e $AMHDir/packages/$Libicu4c_Ver.tar ]; then
		Downloadfile "${Libicu4c_Ver}"-src.tgz "${Ser}/${Libicu4c_Ver}-src.tgz";
		fi;
		tar -zxf $AMHDir/packages/$Libicu4c_Ver-src.tgz -C $AMHDir/packages/untar;
		cd $AMHDir/packages/untar/icu/source;
        ./configure --prefix=/usr/local/icu;
        make -j $Cpunum;
		make install;
# EOF **********************************
echo "/usr/local/lib" >>/etc/ld.so.conf
echo "/usr/local/icu/lib" >>/etc/ld.so.conf
#***************************************
		ldconfig;
		icuPath=/usr/local/icu;
		cd /root;
}
function InstallFreet()
{
    echo "[+] Installing ${Freetype_Ver}";
	if [ ! -e $AMHDir/packages/$Freetype_Ver.tar ]; then
	Downloadfile "${Freetype_Ver}".tar.gz "${Ser}/${Freetype_Ver}.tar.gz";
	fi;
	tar -zxf $AMHDir/packages/$Freetype_Ver.tar.gz -C $AMHDir/packages/untar;
	cd $AMHDir/packages/untar/$Freetype_Ver;
    ./configure --prefix=/usr/local/freetype;
    make -j $Cpunum && make install;
    cat > /etc/ld.so.conf.d/freetype.conf<<EOF
/usr/local/freetype/lib
EOF
    ldconfig;
    ln -sf /usr/local/freetype/include/freetype2 /usr/local/include;
    ln -sf /usr/local/freetype/include/ft2build.h /usr/local/include;
	FreetPath=/usr/local/freetype;
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

	[ "$Inst" == 'yum' ] && chkconfig amh-start off || update-rc.d -f amh-start remove;
	rm -rf /etc/init.d/amh-start;
	rm -rf /usr/local/libiconv;
	rm -rf /usr/local/$OpenSSLVersion;
	rm -rf /usr/local/openssl;
	rm -rf /usr/local/nginx/;
	rm -rf /usr/local/boost_1_59_0/;
	rm -rf /usr/local/icu;
	for line in `ls /root/amh/modules`; do
		amh module $line uninstall;
	done;
	rm -rf /usr/local/mysql/ /etc/my.cnf  /etc/ld.so.conf.d/mysql.conf /usr/bin/mysql /var/lock/subsys/mysql /var/spool/mail/mysql;
	rm -rf /home/mysqldata;
	rm -rf /usr/local/php/ /usr/local/php5.3/ /usr/local/php5.4/ /usr/local/php5.5/ /usr/local/php7.0/ /usr/local/php7.1/ /usr/lib/php /etc/php.ini /etc/php.d /usr/local/zend;
	rm -rf /usr/local/LibMcrypt/ /usr/local/Mcrypt/;
	rm -rf /home/wwwroot/;
	rm -rf /home/proxyroot/;
	rm -rf /etc/pure-ftpd.conf /etc/pam.d/ftp /usr/local/sbin/pure-ftpd /etc/pureftpd.passwd /etc/amh-iptables;
	rm -rf /etc/logrotate.d/nginx /root/.mysqlroot;
	rm -rf /root/amh /bin/amh;
	rm -rf $AMHDir;
	rm -f /usr/bin/{mysqld_safe,myisamchk,mysqldump,mysqladmin,mysql,nginx,php-fpm,phpize,php};
	rm -rf $ImapPath;

	echo '[OK] Successfully uninstall AMH.';
	exit;
}
Install_Boost()
{
    echo "[+] Installing ${Boost_Ver}";
	if [ ! -e $AMHDir/packages/$Boost_Ver.tar.gz ]; then
	Downloadfile "${Boost_Ver}.tar.gz" "${Ser}/${Boost_Ver}.tar.gz";
	fi;
    tar -zxf $AMHDir/packages/$Boost_Ver.tar.gz -C $AMHDir/packages/untar;
    cd $AMHDir/packages/untar/$Boost_Ver;
    ./bootstrap.sh;
    ./b2;
    ./b2 install;
    cd /root;
}
function InstallLibiconv()
{
	echo "[${LibiconvVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$LibiconvVersion.tar.gz ]; then
	Downloadfile "${LibiconvVersion}.tar.gz" "${Ser}/${LibiconvVersion}.tar.gz";
	fi;
	echo "tar -zxf ${LibiconvVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$LibiconvVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/libiconv ]; then
		cd $AMHDir/packages/untar/$LibiconvVersion;
		#rm -rf $AMHDir/packages/untar/$LibiconvVersion/srclib/stdio.in.h;
		#cp $AMHDir/packages/untar/$confver/stdio.in.h $AMHDir/packages/untar/$LibiconvVersion/srclib/stdio.in.h;
		./configure --prefix=/usr/local/libiconv;
		make -j $Cpunum;
		make install;
		echo "[OK] ${LibiconvVersion} install completed.";
	else
		echo '[OK] libiconv is installed!';
	fi;
	
}

function Installlibmcrypt()
{
	echo "[${LibMcryptVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$LibMcryptVersion.tar.gz ]; then
	Downloadfile "${LibMcryptVersion}.tar.gz" "${Ser}/${LibMcryptVersion}.tar.gz";
	fi;
	echo "tar -zxf ${LibMcryptVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$LibMcryptVersion.tar.gz -C $AMHDir/packages/untar;
	
	if [ ! -d /usr/local/LibMcrypt ]; then
		cd $AMHDir/packages/untar/$LibMcryptVersion;
		./configure;
		 make -j $Cpunum;
		 make install;
		 /sbin/ldconfig;
         cd libltdl/;
        ./configure --enable-ltdl-install;
		 make -j $Cpunum;
		 make install;
		 ln -sf /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la;
         ln -sf /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so;
         ln -sf /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4;
         ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8;
         ldconfig;
 		echo "[OK] ${LibMcryptVersion} install completed.";
	else
	   echo '[OK] LibMcrypt is installed!';
fi;	
}
function InstallMhash()
{
	echo "[${MashVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$MashVersion.tar.gz ]; then
	Downloadfile "${MashVersion}.tar.gz" "${Ser}/${MashVersion}.tar.gz";
	fi;
	echo "tar -zxf ${MashVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$MashVersion.tar.gz -C $AMHDir/packages/untar;
		cd $AMHDir/packages/untar/$MashVersion;
		./configure;
		make -j $Cpunum;
		make install;
		 ln -sf /usr/local/lib/libmhash.a /usr/lib/libmhash.a;
         ln -sf /usr/local/lib/libmhash.la /usr/lib/libmhash.la;
         ln -sf /usr/local/lib/libmhash.so /usr/lib/libmhash.so;
         ln -sf /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2;
         ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1;
         ldconfig
		echo "[OK] ${MashVersion} install completed.";
		echo '[OK] Mash is installed!';

}
function InstallMcrypt()
{
	echo "[${McyptVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$McyptVersion.tar.gz ]; then
	Downloadfile "${McyptVersion}.tar.gz" "${Ser}/${McyptVersion}.tar.gz";
	fi;
	echo "tar -zxf ${McyptVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$McyptVersion.tar.gz -C $AMHDir/packages/untar;
	if [ ! -d /usr/local/Mcrypt ]; then
		cd $AMHDir/packages/untar/$McyptVersion;
		LD_LIBRARY_PATH=/usr/local/lib ./configure;
		make -j $Cpunum;
		make install;
		rm -rf $AMHDir/packages/untar/${McyptVersion};
		echo "[OK] ${McyptVersion} install completed.";
	else
		echo '[OK] Mcypt is installed!';
	fi; 
}
function InstallImap()
{
	if [ -s /usr/lib64/libc-client.so ]; then
	ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so;
	echo '[OK] Iamp is installed!';
	else
	echo "[${IampVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$IampVersion.tar.gz ]; then
	Downloadfile "${IampVersion}.tar.gz" "${Ser}/${IampVersion}.tar.gz";
	fi;
	echo "tar -zxf ${IampVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$IampVersion.tar.gz -C $AMHDir/packages/untar;
		cd $AMHDir/packages/untar/$IampVersion;
        make lr5 PASSWDTYPE=std SSLTYPE=unix.nopwd EXTRACFLAGS=-fPIC IP=4;
		rm -rf /usr/local/$IampVersion/;
		mkdir /usr/local/$IampVersion/ /usr/local/$IampVersion/include/ /usr/local/$IampVersion/lib/;
		cp c-client/*.h /usr/local/$IampVersion/include/;
		cp c-client/*.c /usr/local/$IampVersion/lib/;
		cp c-client/c-client.a /usr/local/$IampVersion/lib/libc-client.a;
		ImapPath=/usr/local/${IampVersion};
		rm -rf $AMHDir/packages/untar/${IampVersion};
		echo "[OK] ${IampVersion} install completed.";

fi; 	
}
function InstallOpenSSL()
{
	cd $AMHDir/packages;
	echo "[${OpenSSLVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$OpenSSLVersion.tar.gz ]; then
	Downloadfile "${OpenSSLVersion}.tar.gz" "${Ser}/${OpenSSLVersion}.tar.gz";
    fi;
	echo "tar -zxf ${OpenSSLVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$OpenSSLVersion.tar.gz -C /usr/local;
	#cd /usr/local/$OpenSSLVersion;
	#./config --prefix=/usr/local/openssl shared zlib;
	#make -j $Cpunum;
	#make install;
	#mv /usr/bin/openssl /usr/bin/openssl.old;
    #mv /usr/include/openssl /usr/include/openssl.old;
    #ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl;
    #ln -s /usr/local/openssl/include/openssl /usr/include/openssl;
    #echo "/usr/local/openssl/lib">>/etc/ld.so.conf;
    #ldconfig -v;
	echo "[OK] ${OpenSSLVersion} tar completed.";

}

function InstallMysql55()
{
if [ "$confirm"  == '1' ]; then
	# [dir] /usr/local/mysql/
	echo "[${Mysql55Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Mysql55Version.tar.gz ]; then
	Downloadfile "${Mysql55Version}.tar.gz" "${Ser}/${Mysql55Version}.tar.gz";
	fi;
	echo "tar -zxf ${Mysql55Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Mysql55Version.tar.gz -C $AMHDir/packages/untar;
     if [ ! -f /usr/local/mysql/bin/mysql ]; then
		cd $AMHDir/packages/untar/$Mysql55Version;
		groupadd mysql;
		useradd -s /sbin/nologin -g mysql mysql;
		
		cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1;
		#http://forge.mysql.com/wiki/Autotools_to_CMake_Transition_Guide
		make -j $Cpunum;
		make install;
		chmod +w /usr/local/mysql;
		chown -R mysql:mysql /usr/local/mysql;
		mkdir -p /home/mysqldata;
		chown -R mysql:mysql /home/mysqldata;

		rm -f /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/my.cnf /etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/mysql /root/amh/mysql;
		chmod +x /root/amh/mysql;
		/usr/local/mysql/scripts/mysql_install_db --user=mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/home/mysqldata;
		

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
		echo "[OK] ${Mysql55Version} install completed.";
	else
		echo '[OK] MySQL is installed.';
	fi;
 else
 InstallMysql56;
 fi;
 
}

function InstallMysql56()
{
if [ "$confirm"  == '2' ]; then
	# [dir] /usr/local/mysql/
	echo "[${Mysql56Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Mysql56Version.tar.gz ]; then
	Downloadfile "${Mysql56Version}.tar.gz" "${Ser}/${Mysql56Version}.tar.gz";
	fi;
	echo "tar -zxf ${Mysql56Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Mysql56Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -f /usr/local/mysql/bin/mysql ]; then
		cd $AMHDir/packages/untar/$Mysql56Version;
		groupadd mysql;
		useradd -s /sbin/nologin -g mysql mysql;
		 cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1;
		
		#http://forge.mysql.com/wiki/Autotools_to_CMake_Transition_Guide
		make -j $Cpunum;
		make install;
		chmod +w /usr/local/mysql;
		chown -R mysql:mysql /usr/local/mysql;
		mkdir -p /home/mysqldata;
		chown -R mysql:mysql /home/mysqldata;

		rm -f /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/my56.cnf /etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/mysql /root/amh/mysql;
		chmod +x /root/amh/mysql;
		/usr/local/mysql/scripts/mysql_install_db --user=mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/home/mysqldata;
		

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
		echo "[OK] ${Mysql56Version} install completed.";
	else
		echo '[OK] MySQL is installed.';
	fi;
 else
 InstallMysql57;
 fi;

}

function InstallMysql57()
{
if [ "$confirm"  == '3' ]; then
    
    Install_Boost
	# [dir] /usr/local/mysql/
	echo "[${Mysql57Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Mysql57Version.tar.gz ]; then
	Downloadfile "${Mysql57Version}.tar.gz" "${Ser}/${Mysql57Version}.tar.gz";
	fi;
	echo "tar -zxf ${Mysql57Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Mysql57Version.tar.gz -C $AMHDir/packages/untar;
    if [ ! -f /usr/local/mysql/bin/mysql ]; then
		cd $AMHDir/packages/untar/$Mysql57Version;
		groupadd mysql;
		useradd -s /sbin/nologin -g mysql mysql;
		cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1;
		#http://forge.mysql.com/wiki/Autoto ls_to_CMake_Transition_Guide
		make -j $Cpunum;
		make install;
		chmod +w /usr/local/mysql;
		chown -R mysql:mysql /usr/local/mysql;
		mkdir -p /home/mysqldata;
		chown -R mysql:mysql /home/mysqldata;

		rm -f /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/my57.cnf /etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/mysql /root/amh/mysql;
		chmod +x /root/amh/mysql;
		/usr/local/mysql/bin/mysql_install_db --user=mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/home/mysqldata;
		

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
update user set authentication_string = PASSWORD('$MysqlPass') where user = 'root';
FLUSH PRIVILEGES;
EOF

# **************************************
		echo "[OK] ${Mysql57Version} install completed.";
	else
		echo '[OK] MySQL is installed.';
	fi;
 else
 InstallMariadb55;
 fi;

}

function InstallMariadb55()
{
if [ "$confirm"  == '4' ]; then
	# [dir] /usr/local/mysql/
	echo "[${Mariadb55Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Mariadb55Version.tar.gz ]; then
	Downloadfile "${Mariadb55Version}.tar.gz" "${Ser}/${Mariadb55Version}.tar.gz";
	fi;
	echo "tar -zxf ${Mariadb55Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Mariadb55Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -f /usr/local/mysql/bin/mysql ]; then
		cd $AMHDir/packages/untar/$Mariadb55Version;
		groupadd mysql;
		useradd -s /sbin/nologin -g mysql mysql;
		if [ "$SysName"=='centos' ]; then
         if [ "$RHEL_Ver"=='7' ]; then
		  cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1;
		 fi;
		 else
		  cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1;
		 fi;
		#http://forge.mysql.com/wiki/Autotools_to_CMake_Transition_Guide
		make -j $Cpunum;
		make install;
		chmod +w /usr/local/mysql;
		chown -R mysql:mysql /usr/local/mysql;
		mkdir -p /home/mysqldata;
		chown -R mysql:mysql /home/mysqldata;

		rm -f /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/MariaDB.cnf /etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/mysql /root/amh/mysql;
		chmod +x /root/amh/mysql;
		/usr/local/mysql/scripts/mysql_install_db --user=mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/home/mysqldata;
		

# EOF **********************************
cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
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
		echo "[OK] ${Mariadb55Version} install completed.";
	else
		echo '[OK] MySQL is installed.';
	fi;
 else
 InstallMariadb10;
 fi;
 
}

function InstallMariadb10()
{
if [ "$confirm"  == '5' ]; then
	# [dir] /usr/local/mysql/
	echo "[${Mariadb10Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Mariadb10Version.tar.gz ]; then
	Downloadfile "${Mariadb10Version}.tar.gz" "${Ser}/${Mariadb10Version}.tar.gz";
	fi;
	echo "tar -zxf ${Mariadb10Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Mariadb10Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -f /usr/local/mysql/bin/mysql ]; then
		cd $AMHDir/packages/untar/$Mariadb10Version;
		groupadd mysql;
		useradd -s /sbin/nologin -g mysql mysql;
		 if [ "$SysName"=='centos' ]; then
          if [ "$RHEL_Ver"=='7' ]; then
	      cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1;
		  fi;
		  else
		  cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1;
		  fi;
		#http://forge.mysql.com/wiki/Autotools_to_CMake_Transition_Guide
		make -j $Cpunum;
		make install;
		chmod +w /usr/local/mysql;
		chown -R mysql:mysql /usr/local/mysql;
		mkdir -p /home/mysqldata;
		chown -R mysql:mysql /home/mysqldata;

		rm -f /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/MariaDB.cnf /etc/my.cnf;
		cp $AMHDir/packages/untar/$confver/mysql /root/amh/mysql;
		chmod +x /root/amh/mysql;
		/usr/local/mysql/scripts/mysql_install_db --user=mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/home/mysqldata;
		

# EOF **********************************
cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
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
        #sed -i 's/log_error =.*/log_error = /home/mysqldata/${Domain}.err/' /etc/my.cnf;
        #sed -i 's/pid-file =.*/pid-file = /home/mysqldata/${Domain}.pid/' /etc/my.cnf;
        #sed -i 's/log-bin=mysql-bin.*/#log-bin=mysql-bin' /etc/my.cnf;
        #sed -i 's/short_open_tag =.*/short_open_tag = On/g' /etc/my.cnf;
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
		echo "[OK] ${Mariadb10Version} install completed.";
	else
		echo '[OK] MySQL is installed.';
	fi;
 else
 InstallPhp;
fi;

}

function InstallPhp()
{
   if [ "${Inst}" = 'apt' ]; then
    InstallIcu4c;
	InstallFreet;
    fi;
	if [ "$SysName"=='debian' ]; then
	libc_name=`apt-cache search libc-client.*dev | awk '{print $1}'`;
	#libc_zip=`apt-cache search libzip.*dev | awk '{print $1}'`;
	apt-get install -y $libc_name libzip-dev --force-yes;
	apt-get -f install -y;
	apt-get install -y libzip-dev;
	fi;
	# [dir] /usr/local/php
	echo "[${Php56Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Php56Version.tar.gz ]; then
	Downloadfile "${Php56Version}.tar.gz" "${Ser}/${Php56Version}.tar.gz";
	 fi;
	echo "tar -zxf ${Php56Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Php56Version.tar.gz -C $AMHDir/packages/untar;
	if [ "$SysBit" == '64' ] ; then
		ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so;
		fi;
    if [ ! -d /usr/local/php ]; then
		cd $AMHDir/packages/untar/$Php56Version;
		groupadd www;
		useradd -m -s /sbin/nologin -g www www;
		if [ "${Inst}" = 'apt' ]; then
		ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a;
		ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h;
		./configure --prefix=/usr/local/php --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=$FreetPath --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-icu-dir=$icuPath --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-soap --with-gettext --disable-fileinfo --enable-opcache --with-imap=$ImapPath --enable-intl --with-xsl --enable-zip $PHPDisable;
		else
		if [ "$InstallModel" == '1' ]; then
		 if [ "${Is_ARM}" = 'arm' ]; then
		 yum install -y libzip;
		 export CFLAGS="-L/opt/xml2/lib";
		 export LD_LIBRARY_PATH=/usr/local/mysql/lib;
		 ./configure --prefix=/usr/local/php --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-intl --with-xsl $PHPDisable;
		  else
		 ./configure --prefix=/usr/local/php --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-imap=$ImapPath --with-imap-ssl --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		fi;
		fi;
		fi;
		make -j $Cpunum;
		make install;
		#cp $AMHDir/packages/$Php56Version/php.ini-production /etc/php.ini;
		#cp php.ini-production /usr/local/php/etc/php.ini;
		#mv /etc/php.ini /usr/local/php/etc/php.ini.bak;
		cp $AMHDir/packages/untar/$confver/php.ini /etc/php.ini;
		cp $AMHDir/packages/untar/$confver/php /root/amh/php;
		cp $AMHDir/packages/untar/$confver/phpver /root/amh/phpver;
		mkdir -p /root/amh/fpm/sites;
		mkdir -p /root/amh/sitesconf;
		cp $AMHDir/packages/untar/$confver/php-fpm.conf /usr/local/php/etc/php-fpm.conf;
		cp $AMHDir/packages/untar/$confver/php-fpm-template.conf /root/amh/fpm/php-fpm-template.conf;
		chmod +x /root/amh/php;
		chmod +x /root/amh/phpver;
		mkdir /etc/php.d;
		mkdir /usr/local/php/etc/fpm;
		mkdir /usr/local/php/var/run/pid;
		#mkdir -p /var/run/pid;
		touch /usr/local/php/etc/fpm/amh.conf;
		/usr/local/php/sbin/php-fpm;

		ln -s /usr/local/php/bin/php /usr/bin/php;
		ln -s /usr/local/php/bin/phpize /usr/bin/phpize;
		ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm;
        sed -i 's/post_max_size =.*/post_max_size = 150M/g' /etc/php.ini;
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 150M/g' /etc/php.ini;
        sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /etc/php.ini;
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /etc/php.ini;
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /etc/php.ini;
        sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /etc/php.ini;
# Extension **********************************
#cat > /etc/php.ini<<EOF
#extension=openssl.so
#EOF
# Extension***********************************		
		echo "[OK] ${Php56Version} install completed.";
	else
		echo '[OK] PHP is installed.';
	fi;
}

function InstallPhp53()
{
	# [dir] /usr/local/php5.3
	echo "[${Php53Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Php53Version.tar.gz ]; then
	Downloadfile "${Php53Version}.tar.gz" "${Ser}/${Php53Version}.tar.gz";
	fi;
	echo "tar -zxf ${Php53Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Php53Version.tar.gz -C $AMHDir/packages/untar;
     if [ ! -d /usr/local/php5.3 ]; then
		cd $AMHDir/packages/untar/$Php53Version;
		if [ "${Inst}" = 'apt' ]; then
		LD_LIBRARY_PATH=/usr/local/mysql/lib:/lib/:/usr/lib/:/usr/local/lib ./configure --prefix=/usr/local/php5.3 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.3/etc --with-config-file-scan-dir=/etc/php.d/5.3 --with-openssl --with-zlib --with-icu-dir=$icuPath --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir=$FreetPath --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt --enable-opcache $PHPDisable;
		sed -i '/^BUILD_/ s/\$(CC)/\$(CXX)/g' Makefile;
		else
		if [ "$InstallModel" == '1' ]; then
		 if [ "${Is_ARM}" = 'arm' ]; then
		 LD_LIBRARY_PATH=/usr/local/mysql/lib:/lib/:/usr/lib/:/usr/local/lib ./configure --prefix=/usr/local/php5.3 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.3/etc --with-config-file-scan-dir=/etc/php.d/5.3 --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		 else
		 LD_LIBRARY_PATH=/usr/local/mysql/lib:/lib/:/usr/lib/:/usr/local/lib ./configure --prefix=/usr/local/php5.3 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.3/etc --with-config-file-scan-dir=/etc/php.d/5.3 --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-imap=$ImapPath --with-imap-ssl --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		fi;
		fi;
		fi;
	  if [ "$SysName"=='CentOS' ]; then
       if [ "$RHEL_Ver"=='7' ]; then	
		sed -i '/^BUILD_/ s/\$(CC)/\$(CXX)/g' Makefile;
		else
		echo '[No SED] System No is Centos 7.';
		fi;
		make -j $Cpunum ZEND_EXTRA_LIBS='-liconv';
		make install;
		#cp $AMHDir/packages/$Php53Version/php.ini-production /usr/local/php5.3/etc/php.ini;
		#mv /usr/local/php5.3/etc/php.ini /usr/local/php5.3/etc/php.ini.bak;
		cp $AMHDir/packages/untar/$confver/php53.ini /usr/local/php5.3/etc/php.ini;
		mkdir -p /etc/php.d/5.3;
        sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/register_long_arrays =.*/;register_long_arrays = On/g' /usr/local/php5.3/etc/php.ini;
        sed -i 's/magic_quotes_gpc =.*/;magic_quotes_gpc = On/g' /usr/local/php5.3/etc/php.ini;
# Extension **********************************
#cat > /usr/local/php5.3/etc/php.ini<<EOF
#extension=openssl.so
#EOF
# Extension***********************************
		echo "[OK] ${Php53Version} install completed.";
	else
		echo '[OK] PHP5.3 is installed.';
	fi;
fi;
}

function InstallPhp54()
{
	# [dir] /usr/local/php5.4
	echo "[${Php54Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Php54Version.tar.gz ]; then
	Downloadfile "${Php54Version}.tar.gz" "${Ser}/${Php54Version}.tar.gz";
	fi;
	echo "tar -zxf ${Php54Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Php54Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/php5.4 ]; then
		cd $AMHDir/packages/untar/$Php54Version;
		if [ "${Inst}" = 'apt' ]; then
		./configure --prefix=/usr/local/php5.4 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.4/etc --with-config-file-scan-dir=/etc/php.d/5.4 --with-openssl --with-zlib --with-icu-dir=$icuPath --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir=$FreetPath --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --with-imap=$ImapPath --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		else
		if [ "$InstallModel" == '1' ]; then
		 if [ "${Is_ARM}" = 'arm' ]; then
		    ./configure --prefix=/usr/local/php5.4 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.4/etc --with-config-file-scan-dir=/etc/php.d/5.4 --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		 else
			./configure --prefix=/usr/local/php5.4 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.4/etc --with-config-file-scan-dir=/etc/php.d/5.4 --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-imap=$ImapPath --with-imap-ssl --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		fi;
		fi;
		fi;
		make -j $Cpunum;
		make install;
		#cp $AMHDir/packages/$Php54Version/php.ini-production /usr/local/php5.4/etc/php.ini;
		#mv /usr/local/php5.4/etc/php.ini /usr/local/php5.4/etc/php.ini.bak;
		cp $AMHDir/packages/untar/$confver/php54.ini /usr/local/php5.4/etc/php.ini;
		mkdir -p /etc/php.d/5.4;
        sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php5.4/etc/php.ini;
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php5.4/etc/php.ini;
        sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php5.4/etc/php.ini;
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php5.4/etc/php.ini;
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php5.4/etc/php.ini;
        sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php5.4/etc/php.ini;
# Extension **********************************
#cat > /usr/local/php5.4/etc/php.ini<<EOF
#extension=openssl.so
#EOF
# Extension***********************************
		echo "[OK] ${Php54Version} install completed.";
	else
		echo '[OK] PHP5.4 is installed.';
	fi;
}

function InstallPhp55()
{
	# [dir] /usr/local/php5.5
	echo "[${Php55Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Php55Version.tar.gz ]; then
	Downloadfile "${Php55Version}.tar.gz" "${Ser}/${Php55Version}.tar.gz";
	fi;
	echo "tar -zxf ${Php55Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Php55Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/php5.5 ]; then
		cd $AMHDir/packages/untar/$Php55Version;
		if [ "${Inst}" = 'apt' ]; then
		./configure --prefix=/usr/local/php5.5 --with-config-file-path=/usr/local/php5.5/etc --with-config-file-scan-dir=/etc/php.d/5.5 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=$FreetPath --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-icu-dir=$icuPath --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --with-imap=$ImapPath --enable-intl --with-xsl $PHPDisable;
		else
		if [ "$InstallModel" == '1' ]; then
		if [ "${Is_ARM}" = 'arm' ]; then
		    ./configure --prefix=/usr/local/php5.5 --with-config-file-path=/usr/local/php5.5/etc --with-config-file-scan-dir=/etc/php.d/5.5 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-intl --with-xsl $PHPDisable;
		    else
			./configure --prefix=/usr/local/php5.5 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php5.5/etc --with-config-file-scan-dir=/etc/php.d/5.5 --with-openssl --with-zlib  --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-imap=$ImapPath --with-imap-ssl --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		fi;
		fi;
		fi;
		make -j $Cpunum;
		make install;
		#cp $AMHDir/packages/$Php55Version/php.ini-production /usr/local/php5.5/etc/php.ini;
		#mv /usr/local/php5.5/etc/php.ini /usr/local/php5.5/etc/php.ini.bak;
		cp $AMHDir/packages/untar/$confver/php55.ini /usr/local/php5.5/etc/php.ini;
		mkdir -p /etc/php.d/5.5;
        sed -i 's/post_max_size =.*/post_max_size = 150M/g' /usr/local/php5.5/etc/php.ini;
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 150M/g' /usr/local/php5.5/etc/php.ini;
        sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php5.5/etc/php.ini;
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php5.5/etc/php.ini;
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php5.5/etc/php.ini;
        sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php5.5/etc/php.ini;
# Extension **********************************
#cat > /usr/local/php5.5/etc/php.ini<<EOF
#extension=openssl.so
#EOF
# Extension***********************************
		echo "[OK] ${Php55Version} install completed.";
	else
		echo '[OK] PHP5.5 is installed.';
	fi;
}

function InstallPhp70()
{
	# [dir] /usr/local/php7.0
	echo "[${Php70Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Php70Version.tar.gz ]; then
	Downloadfile "${Php70Version}.tar.gz" "${Ser}/${Php70Version}.tar.gz";
	fi;
	echo "tar -zxf ${Php70Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Php70Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/php7.0 ]; then
		cd $AMHDir/packages/untar/$Php70Version;
		if [ "${Inst}" = 'apt' ]; then
		./configure --prefix=/usr/local/php7.0 --with-config-file-path=/usr/local/php7.0/etc --with-config-file-scan-dir=/etc/php.d/7.0 --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=$FreetPath --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-icu-dir=$icuPath --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --with-imap=$ImapPath --with-xsl --enable-zip $PHPDisable;
		else
		if [ "$InstallModel" == '1' ]; then
		if [ "${Is_ARM}" = 'arm' ]; then
		    ./configure --prefix=/usr/local/php7.0 --with-config-file-path=/usr/local/php7.0/etc --with-config-file-scan-dir=/etc/php.d/7.0 --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --with-xsl $PHPDisable;
		else
			./configure --prefix=/usr/local/php7.0 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php7.0/etc --with-config-file-scan-dir=/etc/php.d/7.0 --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-imap=$ImapPath --with-imap-ssl --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		fi;
		fi;
		fi;
		make -j $Cpunum;
		make install;
		#cp $AMHDir/packages/$Php70Version/php.ini-production /usr/local/php7.0/etc/php.ini;
		#mv /usr/local/php7.0/etc/php.ini /usr/local/php7.0/etc/php.ini.bak;
		cp $AMHDir/packages/untar/$confver/php70.ini /usr/local/php7.0/etc/php.ini;
		mkdir -p /etc/php.d/7.0;
        sed -i 's/post_max_size =.*/post_max_size = 150M/g' /usr/local/php7.0/etc/php.ini;
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 150M/g' /usr/local/php7.0/etc/php.ini;
        sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php7.0/etc/php.ini;
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php7.0/etc/php.ini;
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php7.0/etc/php.ini;
        sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php7.0/etc/php.ini;
# Extension **********************************
#cat > /usr/local/php7.0/etc/php.ini<<EOF
#extension=openssl.so
#EOF
# Extension***********************************
		echo "[OK] ${Php70Version} install completed.";
	else
		echo '[OK] PHP7.0 is installed.';
	fi;
}

function InstallPhp71()
{
	# [dir] /usr/local/php7.1
	echo "[${Php71Version} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$Php71Version.tar.gz ]; then
	Downloadfile "${Php71Version}.tar.gz" "${Ser}/${Php71Version}.tar.gz";
	fi;
	echo "tar -zxf ${Php71Version}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$Php71Version.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /usr/local/php7.1 ]; then
		cd $AMHDir/packages/untar/$Php71Version;
		if [ "${Inst}" = 'apt' ]; then
		./configure --prefix=/usr/local/php7.1 --with-config-file-path=/usr/local/php7.1/etc --with-config-file-scan-dir=/etc/php.d/7.1 --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=$FreetPath --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-icu-dir=$icuPath --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --with-imap=$ImapPath --with-xsl $PHPDisable;
		else
		if [ "$InstallModel" == '1' ]; then
		 if [ "${Is_ARM}" = 'arm' ]; then
		    ./configure --prefix=/usr/local/php7.1 --with-config-file-path=/usr/local/php7.1/etc --with-config-file-scan-dir=/etc/php.d/7.1 --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl/ --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --with-xsl $PHPDisable;
		  else
			./configure --prefix=/usr/local/php7.1 --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-config-file-path=/usr/local/php7.1/etc --with-config-file-scan-dir=/etc/php.d/7.1 --with-openssl --with-zlib --with-curl=/usr/local/curl/ --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-mbstring --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-opcache --enable-sockets --enable-pcntl --with-xmlrpc --with-mhash --enable-soap --with-gettext --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --with-imap=$ImapPath --with-imap-ssl --with-kerberos --without-pear --with-xsl --enable-intl --with-mcrypt $PHPDisable;
		fi;
		fi;
		fi;
		make -j $Cpunum;
		make install;
		#cp $AMHDir/packages/$Php71Version/php.ini-production /usr/local/php7.1/etc/php.ini;
		#mv /usr/local/php7.1/etc/php.ini /usr/local/php7.1/etc/php.ini.bak;
		cp $AMHDir/packages/untar/$confver/php71.ini /usr/local/php7.1/etc/php.ini;
		mkdir -p /etc/php.d/7.1;
        sed -i 's/post_max_size =.*/post_max_size = 150M/g' /usr/local/php7.1/etc/php.ini;
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 150M/g' /usr/local/php7.1/etc/php.ini;
        sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php7.1/etc/php.ini;
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php7.1/etc/php.ini;
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php7.1/etc/php.ini;
        sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php7.1/etc/php.ini;
# Extension **********************************
#cat > /usr/local/php7.1/etc/php.ini<<EOF
#extension=openssl.so
#EOF
# Extension***********************************
		echo "[OK] ${Php71Version} install completed.";
	else
		echo '[OK] PHP7.1 is installed.';
	fi;
}

function InstallNginx()
{
	# [dir] /usr/local/nginx
	echo "[${NginxVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$NginxVersion.tar.gz ]; then
	Downloadfile "${NginxVersion}.tar.gz" "${Ser}/${NginxVersion}.tar.gz";
	fi;
	if [ ! -e $AMHDir/packages/$NginxCachePurgeVersion.tar.gz ]; then
	Downloadfile "${NginxCachePurgeVersion}.tar.gz" "${Ser}/${NginxCachePurgeVersion}.tar.gz";
	fi;
	echo "tar -zxf ${NginxVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$NginxVersion.tar.gz -C $AMHDir/packages/untar;
	echo "tar -zxf ${NginxCachePurgeVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$NginxCachePurgeVersion.tar.gz -C $AMHDir/packages/untar;
	
	#echo-nginx-module-0.58  
	if [ ! -e $AMHDir/packages/$EchoNginxVersion.tar.gz ]; then
	Downloadfile "${EchoNginxVersion}.tar.gz" "${Ser}/${EchoNginxVersion}.tar.gz";
	fi;
    echo "tar -zxf ${EchoNginxVersion}.tar.gz ing...";
    tar -zxf $AMHDir/packages/$EchoNginxVersion.tar.gz -C $AMHDir/packages/untar;

    #ngx_http_substitutions_filter_module-0.6.4
	if [ ! -e $AMHDir/packages/$NgxHttpSubstitutionsFilter.tar.gz ]; then
	Downloadfile "${NgxHttpSubstitutionsFilter}.tar.gz" "${Ser}/${NgxHttpSubstitutionsFilter}.tar.gz";
	fi;
    echo "tar -zxf ${NgxHttpSubstitutionsFilter}.tar.gz ing...";
    tar -zxf $AMHDir/packages/$NgxHttpSubstitutionsFilter.tar.gz -C $AMHDir/packages/untar;
	
	if [ ! -d /usr/local/nginx ]; then
		cd $AMHDir/packages/untar/$NginxVersion;
		if [ "${NVersion}" = 'Nginx' ]; then
		./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module  --with-http_gzip_static_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_uwsgi_module --without-http_scgi_module --with-ipv6 --with-stream --with-http_sub_module --with-http_v2_module --with-openssl=/usr/local/$OpenSSLVersion --add-module=$AMHDir/packages/untar/$NginxCachePurgeVersion --add-module=$AMHDir/packages/untar/$EchoNginxVersion  --add-module=$AMHDir/packages/untar/$NgxHttpSubstitutionsFilter;
		cd /usr/local/$OpenSSLVersion;
		./config;
		cd $AMHDir/packages/untar/$NginxVersion;
		make -j $Cpunum;
		make install;
		else
		cd $AMHDir/packages/untar/$NginxVersion;
		if [ ! -e $AMHDir/packages/openssl-1.0.2e.tar.gz ]; then
		Downloadfile "openssl-1.0.2e.tar.gz" "${Ser}/openssl-1.0.2e.tar.gz";
		fi;
		tar -zxf $AMHDir/packages/openssl-1.0.2e.tar.gz -C /usr/local;
		./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module  --with-http_gzip_static_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_uwsgi_module --without-http_scgi_module --with-ipv6 --with-http_sub_module --with-http_v2_module --with-openssl=/usr/local/openssl-1.0.2e --add-module=$AMHDir/packages/untar/$NginxCachePurgeVersion --add-module=$AMHDir/packages/untar/$EchoNginxVersion  --add-module=$AMHDir/packages/untar/$NgxHttpSubstitutionsFilter;
		make -j $Cpunum;
		make install;
		fi;

	    #./config --prefix=/usr/local/openssl --shared zlib;
	     #make -j $Cpunum;
    	 #make install;
	     #mv /usr/bin/openssl /usr/bin/openssl.old;
         #mv /usr/include/openssl /usr/include/openssl.old;
         #ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl;
         #ln -s /usr/local/openssl/include/openssl /usr/include/openssl;
         #echo "/usr/local/openssl/lib">>/etc/ld.so.conf;
         #ldconfig -v;
		

		
		mkdir -p /home/proxyroot/proxy_temp_dir;
		mkdir -p /home/proxyroot/proxy_cache_dir;
		chown www.www -R  /home/proxyroot/proxy_temp_dir  /home/proxyroot/proxy_cache_dir;
		chmod -R 644  /home/proxyroot/proxy_temp_dir  /home/proxyroot/proxy_cache_dir;

		mkdir -p /home/wwwroot/index /home/backup /usr/local/nginx/conf/vhost/  /usr/local/nginx/conf/vhost_stop/  /usr/local/nginx/conf/rewrite/;
		chown +w /home/wwwroot/index;
		touch /usr/local/nginx/conf/rewrite/amh.conf;

		cp $AMHDir/packages/untar/$confver/proxy.conf /usr/local/nginx/conf/proxy.conf;
		cp $AMHDir/packages/untar/$confver/nginx.conf /usr/local/nginx/conf/nginx.conf;
		cp $AMHDir/packages/untar/$confver/nginx-host.conf /usr/local/nginx/conf/nginx-host.conf;
		cp $AMHDir/packages/untar/$confver/fcgi.conf /usr/local/nginx/conf/fcgi.conf;
		cp $AMHDir/packages/untar/$confver/fcgi-host.conf /usr/local/nginx/conf/fcgi-host.conf;
		cp $AMHDir/packages/untar/$confver/nginx /root/amh/nginx;
		cp $AMHDir/packages/untar/$confver/host /root/amh/host;
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
	if [ ! -e $AMHDir/packages/$PureFTPdVersion.tar.gz ]; then
	Downloadfile "${PureFTPdVersion}.tar.gz" "${Ser}/${PureFTPdVersion}.tar.gz";
	fi;
	echo "tar -zxf ${PureFTPdVersion}.tar.gz ing...";
	tar -zxf $AMHDir/packages/$PureFTPdVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -f /etc/pure-ftpd.conf ]; then
		cd $AMHDir/packages/untar/$PureFTPdVersion;
		if [ "${Inst}" = 'apt' ]; then
		./configure CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg --with-throttling --with-uploadscript --with-language=english --with-rfc2640 --with-ftpwho --with-tls;
		else
		./configure --with-puredb --with-quotas --with-throttling --with-ratios --with-peruserlimits;
		fi;
		make -j $Cpunum;
		make install;
		cp contrib/redhat.init /usr/local/sbin/redhat.init;
		chmod 755 /usr/local/sbin/redhat.init;

		cp $AMHDir/packages/untar/$confver/pure-ftpd.conf /etc;
		cp configuration-file/pure-config.pl /usr/local/sbin/pure-config.pl;
		chmod 744 /etc/pure-ftpd.conf;
		chmod 755 /usr/local/sbin/pure-config.pl;
		/usr/local/sbin/redhat.init start;

		groupadd ftpgroup;
		useradd -d /home/wwwroot/ -s /sbin/nologin -g ftpgroup ftpuser;

		cp $AMHDir/packages/untar/$confver/ftp /root/amh/ftp;
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
	if [ ! -e $AMHDir/packages/$AMHVersion.tar.gz ]; then
	Downloadfile "${AMHVersion}.tar.gz" "${Ser}/${AMHVersion}.tar.gz";
	fi;
	echo "tar -xf ${AMHVersion}.tar.gz ing...";
	tar -xf $AMHDir/packages/$AMHVersion.tar.gz -C $AMHDir/packages/untar;

	if [ ! -d /home/wwwroot/index/web ]; then
		cp -r $AMHDir/packages/untar/$AMHVersion /home/wwwroot/index/web;

		gcc -o /bin/amh -Wall $AMHDir/packages/untar/$confver/amh.c;
		chmod 4775 /bin/amh;
		cp -a $AMHDir/packages/untar/$confver/amh-backup.conf /home/wwwroot/index/etc;
		cp -a $AMHDir/packages/untar/$confver/html /home/wwwroot/index/etc;
		cp $AMHDir/packages/untar/$confver/{all,backup,revert,BRssh,BRftp,info,SetParam,module,crontab,upgrade} /root/amh;
		cp -a $AMHDir/packages/untar/$confver/modules /root/amh;
		chmod +x /root/amh/all /root/amh/backup /root/amh/revert /root/amh/BRssh /root/amh/BRftp /root/amh/info /root/amh/SetParam /root/amh/module /root/amh/crontab /root/amh/upgrade;

		SedMysqlPass=${MysqlPass//&/\\\&};
		SedMysqlPass=${SedMysqlPass//\'/\\\\\'};
		sed -i "s/'MysqlPass'/'${SedMysqlPass}'/g" /home/wwwroot/index/web/Amysql/Config.php;
		chown www:www /home/wwwroot/index/web/Amysql/Config.php;

		SedAMHPass=${AMHPass//&/\\\&};
		SedAMHPass=${SedAMHPass//\'/\\\\\\\\\'\'};
		sed -i "s/'AMHPass_amysql-amh'/'${SedAMHPass}_amysql-amh'/g" $AMHDir/packages/untar/$confver/amh.sql;
		/usr/local/mysql/bin/mysql -u root -p$MysqlPass < $AMHDir/packages/untar/$confver/amh.sql;
        #sed -i 's/AMH 4.2/'AMH 4.5'/g' /home/wwwroot/index/web/View/index.php
        #sed -i 's/Nginx 1.* /' $NginxVersion/\u&'/g' /home/wwwroot/index/web/View/index.php;
        #sed -i 's/Mariadb-10.1.13/'$Mariadb10Version'/g' /home/wwwroot/index/web/View/index.php;
		#sed -i 's/<br>PHP 5.* <br/>/'<br>$Php56Version</br>'/g' /home/wwwroot/index/web/View/index.php;
		 if [ "$SysName"=='debian' ]; then
           rm -rf /etc/apt/sources.list;
           mv /etc/apt/sources.list.bak /etc/apt/sources.list;
           apt-get update;
		      	else
           echo '[No rm mv] System No is Debian.';
         fi;
		if [ "${NVersion}" = 'Tengine' ]; then
		sed -i '/Nginx 1.9.9 /a\<br>Tengine 2.2.0<br/>'  /home/wwwroot/index/web/View/index.php;
		fi;
		if [ "$confirm71" == 'y' ]; then
		sed -i '/PHP 5.6.30 /a\<br>PHP 7.1.3<br/>'  /home/wwwroot/index/web/View/index.php;
		fi;
		if [ "$confirm70" == 'y' ]; then
		sed -i '/PHP 5.6.30 /a\<br>PHP 7.0.17<br/>'  /home/wwwroot/index/web/View/index.php;
		fi;
		if [ "$confirm55" == 'y' ]; then
		sed -i '/PHP 5.6.30 /a\<br>PHP 5.5.38<br/>'  /home/wwwroot/index/web/View/index.php;
		fi;
		if [ "$confirm54" == 'y' ]; then
		sed -i '/PHP 5.6.30 /a\<br>PHP 5.4.45<br/>'  /home/wwwroot/index/web/View/index.php;
		fi;
		if [ "$confirm53" == 'y' ]; then
		sed -i '/PHP 5.6.30 /a\<br>PHP 5.3.29<br/>'  /home/wwwroot/index/web/View/index.php;
		fi;
       if [ "$SysName"=='centos' ]; then
       if [ "$RHEL_Ver"=='7' ]; then
	   rm -rf /root/amh/info;
	   cp $AMHDir/packages/untar/$confver/info7 /root/amh/info;
	   chmod 755 /root/amh/info;
	   #rm -rf /home/wwwroot/index/web/View/infos.php;
	   #cp $AMHDir/packages/untar/$confver/infos.php /home/wwwroot/index/web/View;
	   fi;
		echo "[OK] ${AMHVersion} install completed.";
	else
		echo '[OK] AMH is installed.';
	fi;
fi;
}

function InstallAMS()
{
	# [dir] /home/wwwroot/index/web/ams
	echo "[${AMSVersion} Installing] ************************************************** >>";
	if [ ! -e $AMHDir/packages/$AMSVersion.tar.gz ]; then
	Downloadfile "${AMSVersion}.tar.gz" "${Ser}/${AMSVersion}.tar.gz";
	fi;
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
#SystemName;
ConfirmInstall;
#ConfirmDomain;
[ "$ConfirmDomain" == 'y' ] && Domain;
RHELVersion;
InputDomain;
InputMysqlPass;
InputAMHPass;
Timezone;
CloseSelinux;
DeletePackages;
InstallBasePackages;
Download;
InstallReady;
Installcurl;
InstallLibiconv;
Installlibmcrypt;
InstallMhash;
InstallMcrypt;
InstallImap;
#InstallMysql;
InstallMysql55;
InstallMysql56;
InstallMysql57;
InstallMariadb55;
InstallMariadb10;
InstallPhp;
[ "$confirm53" == 'y' ] && InstallPhp53;
[ "$confirm54" == 'y' ] && InstallPhp54;
[ "$confirm55" == 'y' ] && InstallPhp55;
[ "$confirm70" == 'y' ] && InstallPhp70;
[ "$confirm71" == 'y' ] && InstallPhp71;
InstallOpenSSL;
InstallNginx;
InstallPureFTPd;
InstallAMH;
InstallAMS;


if [ -s /usr/local/nginx ] && [ -s /usr/local/php ] && [ -s /usr/local/mysql ]; then

cp $AMHDir/packages/untar/$confver/amh-start /etc/init.d/amh-start;
chmod 775 /etc/init.d/amh-start;
if [ "$Inst" == 'yum' ]; then
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
	echo 'MySQL-Data: /home/mysqldata';
	echo '';
	echo "Start time: ${StartDate}";
	echo "Completion time: $(date) (Use: $[($(date +%s)-StartDateSecond)/60] minute)";
	echo 'More help please visit:http://amysql.com '' http://www.sxsay.com';
echo '================================================================';
else
	echo 'Sorry, Failed to install AMH';
	echo 'Please contact us: http://amysql.com '' http://www.sxsay.com';
fi;
