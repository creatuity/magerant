#
# Cookbook Name:: magedev
# Recipe:: clone
#
# Copyright 2014, Creatuity Corp.
#
# Licensed under the GPLv2 or newer, at your preference.
#

include_recipe "database::mysql"

execute "git clone" do 
	cwd "/var/www/"
	command "git clone #{node['magedev']['gitRepo']} html"
	returns [0, 1] # on Windows, returns 0 for some reason
	action :run
	not_if do
		File.exists?("/var/www/html/.git/HEAD")
	end
end

execute "git pull" do
        cwd "/var/www/html/"
        command "git pull"
        returns [0, 1] # this may be 0 if we're already up to date
        action :run
        not_if do
                !File.exists?("/var/www/html/.git/HEAD")
        end
end

mysqldump '/mnt/sqldumps/db.sql' do
	dbhost node['magedev']['mysql_source_host']
	dbuser node['magedev']['mysql_source_user']
	dbpassword node['magedev']['mysql_source_password']
	dbname node['magedev']['mysql_source_dbname']
	overwrite true
    not_if do
    	File.exists?("/mnt/sqldumps/db.sql")
    end

end

mysqldump '/mnt/sqldumps/wp_db.sql' do
	dbhost node['magedev']['mysql_source_host']
	dbuser node['magedev']['mysql_source_user']
	dbpassword node['magedev']['mysql_source_password']
	dbname node['magedev']['mysql_source_dbname_wp']
	overwrite true
	not_if do
		File.exists?("/mnt/sqldumps/wp_db.sql")
	end
end

execute "install mysql-dump-split" do
    cwd "/mnt/sqldumps/"
    # have to use no-check-certificate due to github cert issue
    command "wget --no-check-certificate https://raw.githubusercontent.com/md2perpe/mysql-dump-split/master/split-mysql-dump.rb"
    action :run
    not_if do
        File.exists?("/mnt/sqldumps/split-mysql-dump.rb")
    end
end

mysql_connect_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => 'yolo'
}

mysql_database 'mage_db' do
	connection mysql_connect_info
	action :create
end

mysql_database 'wp_db' do
	connection mysql_connect_info
	action :create
end

mysql_database 'run script' do
	connection mysql_connect_info
	sql 'set global net_buffer_length=1000000;' 
  	action :query
end

mysql_database 'run script' do
	connection mysql_connect_info
	sql 'set global max_allowed_packet=1000000000;' 
  	action :query
end

bash "split Magento database dump" do
    user "root"
    cwd "/mnt/sqldumps/"
    code <<-EOH
        rm -rf /mnt/sqldumps/tables
        rm -rf /mnt/sqldumps/mage_db/
        mkdir /mnt/sqldumps/mage_db/
        mkdir /mnt/sqldumps/mage_db/tables/
        ./split-mysql-dump.rb --use-database mage_db db.sql
    EOH
end

bash "import split Magento database dump" do
    user "root"
    cwd "/mnt/sqldumps/mage_db/tables/"
    code <<-EOH
        FILES=/mnt/sqldumps/mage_db/tables/*
        for f in $FILES
        do
            echo "Importing $f"
            sed -i "1iSET foreign_key_checks = 0;" $f
            sed -i "1i/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;" $f
            sed -i "1i/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;" $f
            sed -i "1i/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;" $f
            sed -i "1i/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;" $f
            sed -i "1i/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;" $f
            sed -i "1i/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;" $f
            sed -i "1i/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;" $f
            sed -i "1i/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;" $f
            mysql -u root --password=yolo mage_db < $f
        done
    EOH
end

#mysql_database 'run script' do
#	connection mysql_connect_info
#	database_name 'mage_db'
#	sql { ::File.open('/mnt/sqldumps/db.sql').read }
#  	action :query
#end

mysql_database 'run script' do
	connection mysql_connect_info
	database_name 'mage_db'
	sql 'UPDATE core_config_data SET value = "http://magento.localhost:8080/" WHERE path LIKE "%base_url%" AND scope_id = 0;'
  	action :query
end


#mysql_database 'run script' do
#	connection mysql_connect_info
#	database_name 'wp_db'
#	sql { ::File.open('/mnt/sqldumps/wp_db.sql').read }
#  	action :query
#end

bash "split WordPress database dump" do
    user "root"
    cwd "/mnt/sqldumps/"
    code <<-EOH
        rm -rf /mnt/sqldumps/tables
        rm -rf /mnt/sqldumps/wp_db/
        mkdir /mnt/sqldumps/wp_db/
        mkdir /mnt/sqldumps/wp_db/tables/
        ./split-mysql-dump.rb --use-database wp_db wp_db.sql
    EOH
end

bash "import split WordPress database dump" do
    user "root"
    cwd "/mnt/sqldumps/wp_db/tables/"
    code <<-EOH
        FILES=/mnt/sqldumps/wp_db/tables/*
        for f in $FILES
        do
            echo "Importing $f"
            sed -i "1iSET foreign_key_checks = 0;" $f
            sed -i "1i/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;" $f
            sed -i "1i/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;" $f
            sed -i "1i/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;" $f
            sed -i "1i/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;" $f
            sed -i "1i/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;" $f
            sed -i "1i/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;" $f
            sed -i "1i/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;" $f
            sed -i "1i/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;" $f
            mysql -u root --password=yolo wp_db < $f
        done
    EOH
end

bash "clean up after split database dump" do
    user "root"
    cwd "/mnt/sqldumps/"
    code <<-EOH
        rm -rf /mnt/sqldumps/wp_db
        rm -rf /mnt/sqldumps/mage_db
    EOH
end


mysql_database 'run script' do
	connection mysql_connect_info
	database_name 'wp_db'
	sql 'UPDATE wp_options SET option_value = "http://magento.localhost:8080/wordpress/" WHERE option_name = "siteurl"';
  	action :query
end

mysql_database 'run script' do
	connection mysql_connect_info
	database_name 'wp_db'
	sql 'UPDATE wp_options SET option_value = "http://magento.localhost:8080/blog/" WHERE option_name = "home"';
  	action :query
end

bash "setup local.xml" do
    user "root"
    cwd "/var/www/html/app/etc/"
    code <<-EOH
        cp -f /mnt/sqldumps/local.xml /var/www/html/app/etc/local.xml
    EOH
end

bash "setup wp-config.php" do
    user "root"
    cwd "/var/www/html/wordpress/"
    code <<-EOH
        cp -f /mnt/sqldumps/wp-config.php /var/www/html/wordpress/wp-config.php
    EOH
end

bash "clear cache" do
    user "root"
    cwd "/var/www/html/"
    code <<-EOH
        magerun cache:flush
        magerun cache:disable
        php shell/compiler.php clear
        php shell/compiler.php disable
    EOH
end
