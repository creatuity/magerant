# -*- mode: ruby -*-
# vi: set ft=ruby :

require Dir.pwd + '/projectconfig.rb'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "CentOS-6.4-x86_64-v20131103"
  #config.vm.box = "centos65"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20131103.box"
  #config.vm.box_url = "http://www.lyricalsoftware.com/downloads/centos65.box"

  

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./www-data", "/var/www/html/", :mount_options => ["dmode=777,fmode=777"] # VirtualBox shared directory workaround
  config.vm.synced_folder "./sqldumps", "/mnt/sqldumps/", :mount_options => ["dmode=777,fmode=777"] # VirtualBox shared directory workaround
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  vb.customize ["modifyvm", :id, "--memory", "3072"]
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision "chef_solo" do |chef|
     chef.cookbooks_path = "./chef-recipes/cookbooks"
     chef.roles_path = "./chef-recipes/roles"
     chef.data_bags_path = "./chef-recipes/data_bags"
	chef.add_recipe "apache2"
	chef.add_recipe "apache2::mod_php5"
	chef.add_recipe "mysql::client"
	chef.add_recipe "mysql::server"
	chef.add_recipe "php"
	chef.add_recipe "composer"
	chef.add_recipe "git"
	chef.add_recipe "database"
	chef.add_recipe "mysqldump"
	chef.add_recipe "yum"
	chef.add_recipe "magedev"
	chef.add_recipe "magedev::clone"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
      chef.json = { 
			:mysql => { "server_root_password" => 'yolo' },  
			:apache => { :default_site_enabled => true }, 
			:magedev => { 
				 "gitRepo" => $gitRepo,
				 "mysql_source_dbname" => $mysql_source_dbname,
				 "mysql_source_dbname_wp" => $mysql_source_dbname_wp,   
				 "user" => "vagrant",
			         "group" => "vagrant",
        			 "known_hosts" => IO.read(File.expand_path("~/.ssh/known_hosts")),
        			 "public_key" => IO.read(File.expand_path("~/.ssh/id_rsa.pub")),
        			 "private_key" => IO.read(File.expand_path("~/.ssh/id_rsa")),
				 "mysql_source_host" => $mysql_source_host,
				 "mysql_source_user" => $mysql_source_user,
				 "mysql_source_password" => $mysql_source_password,
				 
					}  
			
		  }
  end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
