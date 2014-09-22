# Jiff

Jiff is a server management tool which can manage Apache based web servers running Rails apps. It integrates with Uptime Robot, New Relic and Github to provide a central place to manage and view info on hosted sites and servers.

## Dev Info

Install the gems through bundler as usual and then ensure Vagrant is set up.

### Setting up Vagrant

1. Install Vagrant (https://www.vagrantup.com/downloads.html) and VirtualBox (https://www.virtualbox.org/wiki/Downloads)

2. Install the following Vagrant plugins:

```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-librarian-chef
```

3. Insert the following into ~/.ssh/config

```
Host default
	HostName 127.0.0.1
	User vagrant
	Port 2222
	UserKnownHostsFile /dev/null
	StrictHostKeyChecking no
	PasswordAuthentication no
	IdentityFile ~/.vagrant.d/insecure_private_key
	IdentitiesOnly yes
	LogLevel FATAL
```

4. Run `vagrant up` within the project directory.

### Finishing up

Once Vagrant is fully up and running, run the rake task `jiff:launch` which will load in some default data. Everything should now be ready to go.
