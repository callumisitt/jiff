# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use Ubuntu 12.04 Precise Pangolin 32-bit as our operating system
  config.vm.box = "ubuntu/precise32"
  
  # Use latest version of chef
  config.omnibus.chef_version = :latest
  
  # Port forwarding
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]

    chef.add_recipe "apt"
    chef.add_recipe "apache2"
    chef.add_recipe "passenger_apache2"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rbenv::user"
    chef.add_recipe "rbenv::vagrant"
    chef.add_recipe "vim"
    chef.add_recipe "mysql::server"
    chef.add_recipe "mysql::client"

    # Install Ruby 2.1.1 & Bundler and set up MySQL
    chef.json = {
      rbenv: {
        user_installs: [{
          user: 'vagrant',
          rubies: ["2.1.1"],
          global: "2.1.1",
          gems: {
            "2.1.1" => [
              { name: "bundler" }
            ]
          }
        }]
      },
      mysql: {
        server_root_password: '***REMOVED***'
      }
    }
  end
end
