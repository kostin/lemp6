#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
echo 'nameserver 77.88.8.8' >> /etc/resolv.conf

killall -9 httpd
yum -y remove httpd
yum -y install epel-release
sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo

rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

if [ `uname -m` == 'x86_64' ]; then
cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
else
cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos6-x86
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
fi

yum -y update

yum -y install pwgen screen git mc sysstat
yum -y install MariaDB-server
yum -y install php55w-common php55w-opcache php55w-cli php55w-fpm php55w-gd php55w-mbstring php55w-mcrypt php55w-mysql php55w-pdo php55w-xml
yum -y install nginx16

echo "#!/bin/bash" > /etc/profile.d/php-cli.sh
echo 'alias php="php -c /etc/php-cli.ini"' >> /etc/profile.d/php-cli.sh
echo "magic_quotes_gpc = Off" > /etc/php-cli.ini

service mysql start
chkconfig mysql on
service nginx start
chkconfig nginx on
service php-fpm start
chkconfig php-fpm on

if [ -f /root/.mysql-root-password ]; then 
	MYSQLPASS=`cat /root/.mysql-root-password`	
	echo 'MySQL root password already set up'
else
	MYSQLPASS=`pwgen 24 1`
	echo $MYSQLPASS > /root/.mysql-root-password
	echo "MySQL root password is $MYSQLPASS and it stored in /root/.mysql-root-password"
	mysqladmin -u root password $MYSQLPASS
	mysql -p$MYSQLPASS -B -N -e "drop database test"	
fi