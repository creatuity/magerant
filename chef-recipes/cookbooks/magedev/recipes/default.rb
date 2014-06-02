#
# Cookbook Name:: magedev
# Recipe:: default
#
# Copyright 2014, Creatuity Corp.
#
# Licensed under the GPLv2 or newer, at your preference.
#

include_recipe "database::mysql"

#making sure epel is enabled
yum_repository 'epel' do
    mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
    description 'Extra Packages for Enterprise Linux 6 - $basearch'
    enabled true
    gpgcheck true
    gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
end

#execute "install nodejs" do
#	command "yum -y install nodejs"
#	action :run
#end

execute "install nano" do
	command "yum -y install nano"
	action :run
end

execute "install man" do
	command "yum -y install man"
	action :run
end

execute "install epel-release" do
	command "yum -y install epel-release"
	action :run
end

execute "install remi repo" do
	command "rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
	action :run
end

execute "upgrade to php55" do
	command "yum -y update php --enablerepo=remi,remi-php55"
	action :run
end

execute "install a few assorted PHP packages" do
	command "yum -y install xhprof php-phpunit-DbUnit php-phpunit-PHP-TokenStream php-channel-pdepend php-channel-phpdoc php-channel-phpmd php-channel-phpqatools php-channel-phpseclib php-channel-phpunit php-pear php-pear-PhpDocumentor php-pecl-xdebug php-phpmd-PHP-PMD php-phpunit-PHP-CodeBrowser php-phpunit-PHP-CodeCoverage php-phpunit-PHP-Invoker php-phpunit-PHP-Timer php-phpunit-PHPUnit php-phpunit-PHPUnit-MockObject php-phpunit-PHPUnit-Story php-phpunit-Version php-phpunit-exporter php-phpunit-phpcpd php-phpunit-phpdcd php-phpunit-phploc php-pdepend-PHP-Depend php-pdo php-mcrypt php-gd php-ZendFramework-Db-Adapter-Pdo-Mysql --enablerepo=remi,remi-php55"
	action :run
end

execute "install nodejs, npm" do
	command "yum -y install nodejs npm"
	action :run
end

execute "install sass" do
	command "gem install sass"
	action :run
end

execute "install compass" do
	command "gem install compass"
	action :run
end

bash "disable iptables" do
	user "root"
	code <<-EOH
	/etc/init.d/iptables stop
	EOH
end

# setup ssh keys
file "/home/vagrant/.ssh/id_rsa" do
  owner node['magedev']['user']
  group node['magedev']['group']
  mode "0600"
  content node['magedev']['private_key']
  action :create
end

file "/home/vagrant/.ssh/id_rsa.pub" do
  owner node['magedev']['user']
  group node['magedev']['group']
  mode "0600"
  content node['magedev']['public_key']
  action :create
end

file "/home/vagrant/.ssh/known_hosts" do
  owner node['magedev']['user']
  group node['magedev']['group']
  mode "0600"
  content node['magedev']['known_hosts']
  action :create
end

# setup ssh keys under root account as well

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/root/.ssh/id_rsa" do
  owner "root"
  group "root"
  mode "0600"
  content node['magedev']['private_key']
  action :create
end

file "/root/.ssh/id_rsa.pub" do
  owner "root"
  group "root"
  mode "0600"
  content node['magedev']['public_key']
  action :create
end

file "/root/.ssh/known_hosts" do
  owner "root"
  group "root"
  mode "0600"
  content node['magedev']['known_hosts']
  action :create
end

file "/etc/my.cnf" do 
	owner "mysql"
	group "mysql"
	mode "0600"
	content <<-config
[client]
port                           = 3306
socket                         = /var/lib/mysql/mysql.sock

[mysqld_safe]
socket                         = /var/lib/mysql/mysql.sock

[mysqld]
user                           = mysql
pid-file                       = /var/run/mysql/mysql.pid
socket                         = /var/lib/mysql/mysql.sock
port                           = 3306
datadir                        = /var/lib/mysql
max_allowed_packet	       = 728M

[mysql]
!includedir /etc/mysql/conf.d
config
	action :create
end 

execute "restart mysql" do
        command "/etc/init.d/mysqld restart"
        action :run
end

execute "restart apache" do
        command "/etc/init.d/httpd restart"
        action :run
end

bash "install magerun and modman" do
    user "root"
    cwd "/usr/src/"
    code <<-EOH
        git clone https://github.com/netz98/n98-magerun
        curl -s https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer.phar
        ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
        cd /usr/src/n98-magerun
        cp -f /mnt/sqldumps/magerun-composer.json /usr/src/n98-magerun/composer.json
        composer install
        mv /usr/src/n98-magerun/n98-magerun.phar /usr/local/bin/n98-magerun.phar
        ln -s /usr/local/bin/n98-magerun.phar /usr/local/bin/magerun
        cd /usr/local/bin
        wget --no-check-certificate https://raw.githubusercontent.com/colinmollenhour/modman/master/modman
        chmod a+x /usr/local/bin/modman
    EOH
end
