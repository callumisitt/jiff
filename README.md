# Jiff

Jiff is a server management tool which can manage Apache based web servers running Rails apps. It integrates with Uptime Robot, New Relic and Github to provide a central place to manage and view info on hosted sites and servers.

## Dev Info

Install the gems through bundler as usual and then ensure Vagrant is set up.

### Setting up Vagrant

1. Install Vagrant (https://www.vagrantup.com/downloads.html) and VirtualBox (https://www.virtualbox.org/wiki/Downloads).
2. Install the following Vagrant plugins:

	```
	vagrant plugin install vagrant-omnibus
	vagrant plugin install vagrant-librarian-chef
	```

3. Insert the following into `~/.ssh/config`

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

4. Ensure the environment variables with the New Relic, Uptime Robot and GitHub API Keys are added to `~/.bash_profile`

5. Run `vagrant up` within the project directory.

### Deploying a Test Site

An existing Rails site can be made to deploy to the Vagrant box.

1. Add `gem 'capistrano-rbenv', '1.0.5'` to the `development` group in the site's `Gemfile` and run a `bundle install`

2. Add `require 'capistrano-rbenv'` to `config/deploy.rb`

3. Add a `vagrant` block to `config/database.yml` with the following details (make sure to change the DB name):

	```
	vagrant:
		adapter: mysql2
		host: 127.0.0.1
		username: root
		database: `DB NAME`
	```

4. Create the file `config/deploy/vagrant.rb` and enter the following (make sure to change the site name):

	```
	# The name of your application.  Used for deployment directory and filenames
	# and Apache configs. Should be unique on the Brightbox
	set :application, `SITE NAME`

	set :domain, '`SITE NAME`.default'

	## List of servers
	server 'default', :app, :web, :db, primary: true
	set :rails_env, 'staging'
	set :branch, 'develop'
	set :user, 'vagrant'

	set :rbenv_type, :user # or :system, depends on your rbenv setup
	set :rbenv_ruby, '2.1.1-p76'
	set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
	set :rbenv_map_bins, %w{rake gem bundle ruby rails}
	set :rbenv_roles, :all # default value
	```
	
5. Run `cap vagrant deploy`

6. SSH into the Vagrant box and CD into the site's current directory. Once in there, run `rake db:create` if the database is not already created.

7. Create a Virtual Host config file for the site if it does not already exist. Nothing special is required for the config so one can be copied from another server.

8. After a reload of Apache, the site should now be accessible at `SITE NAME.localhost:8080`

### Finishing up

Once Vagrant is fully up and running, run the rake task `jiff:launch` which will load in some default data. Everything should now be ready to go.
