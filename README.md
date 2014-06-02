magerant
========

Summary
-------

Magerant is a Vagrant + Chef solo setup for quickly creating a new Magento-focused VM and a Magento dev instance from an existing project.

Currently, it was designed around a specific client site that contained 2 databases - one for Magento and one for WordPress - but "soon" I will update it to work with single databases, Magento+a CMS in the same DB, etc.

Warnings
--------

BANDWIDTH WARNING: Vagrant downloads a complete VM image (~500MB) followed by a number of updates and additional packages. If you're on a capped or metered connection, please be aware that you could end up downloading ~1GB.

PATIENCE WARNING: The initial 'vagrant up' takes time - depending on your machine, it can take a long time. This is because Chef will gather the latest version of PHP 5.5 and a number of other resources and install/update them before it's done. It only does this on the first "vagrant up" run, subsequent "vagrant up" commands are much, much faster.

SECURITY WARNING: The virtual machine created by magerant is designed for development use only. DO NOT USE MAGERANT IN PRODUCTION. Please be aware that the Magerant VM will be available via SSH on port 2222 and HTTP on port 8080. If you are not running a firewall on the machine running Magerant, anyone with network access to your machine will be able to access these services on the Magerant VM.

Basically - if you break things, get hacked or get a big bill from your cellular provider because you decided to try this over 3G tethering, it's not our fault. Use common sense.

Using Magerant
--------------

In order to use Magerant, you should:

1) Install Vagrant and Virtualbox if you haven't already:

http://www.vagrantup.com/downloads.html
https://www.virtualbox.org/wiki/Downloads

2) Clone this repository to wherever you'd like to create your Vagrant box.

3) Edit projectconfig.rb. The variable names should be fairly self-explanatory, but are also explained below:

$gitRepo - the complete path to the git repository containing your Magento project, including the protocol.
$mysql_source_dbname - the name of your MySQL database containing the Magento site
$mysql_source_dbname_wp - the name of the MySQL database containing a WordPress site.
$mysql_source_host - the hostname or IP address of the MySQL server
$mysql_source_user - a MySQL user that can access these databases
$mysql_source_password  - the password for the above MySQL user

4) Edit sqldumps/local.xml. Change the phrase "INSERT CRYPT KEY FOR YOUR SITE HERE" to the crypt key found in the local.xml for the site you're working on.

5) Run: git submodule init; git submodule update

6) Optional: edit Vagrantfile and change the amount of memory allocated to the VM. It's currently set to 3GB. Find the line "vb.customize ["modifyvm", :id, "--memory", "3072"]" and change 3072 to your preferred amount of memory in megabytes.

7) Run: vagrant up

This will start the process of setting up the virtual machine. It will download a CentOS 6.4 base image and then run a number of Chef recipes, including:

 * Install and configure apache2, mysql, php, composer, git
 * Run the Chef 'magedev' default and 'clone' recipe, which are a new Chef cookbook created just for this project.
 * Chef 'magedev'
 * Copy the SSH key and known_hosts files from your current user to the Magerant VM so that you can git clone/etc. from within the VM.
 * Set the MySQL root user's password to 'yolo' (don't blame me, that comes from upstream)
 * Magedev::default enables the EPEL and Remi repos in yum, installs nano, php 5.5, nodejs, npm, sass and compass, magerun and modman
 * Magedev::clone git clones or git updates your site's code and then makes a DB dump and changes the baseurl in the dev database. Finally, it clears and disables the Magento caches on the dev copy in the VM

As you wait for vagrant up to complete, now is a good time to edit your hosts file - the Magerant VM expects your hosts file to contain an entry pointing magento.localhost to 127.0.0.1.

8) Once Vagrant is done starting up, access your new dev instance by visting http://magento.localhost:8080/

You'll find the code cloned at <directory you checked magerant out to>/www-data/ - any changes you make to that directory on your local machine will show up immediately on you dev instance. Use your favorite IDE and Git tools to work on those files.

Contributing to Magerant
------------------------

Contributions are welcomed and encouraged. Please submit issues or pull requests on GitHub.

Copyright / License Information
-------------------------------

Magerant is Copyright (C) 2014 Creatuity Corp. and is released under the GPLv2, or newer, at your preference.

This copyright and license applies only to the new work produced by Creatuity Corp. Magerant stands on the shoulders of many giants, including composer, magerun, modman and other great Magento or PHP tools. Those tools remain the property of their original authors and are licensed under the terms stated by their original authors.

This copyright and license does NOT apply to any code placed in the 'sqldumps' or 'www-data' directories. Your code remains your own code to copyright and license as you see fit, even if you use the Magerant system to test it.

By contributing to Magerant via GitHub, you agree to license your contributions under the GPLv2, or newer, and you agree to have Creatuity distribute them via the Magerant GitHub repository.

