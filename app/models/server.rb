class Server < ActiveRecord::Base
  require 'net/ssh'
    
  has_many :sites
  
  attr_accessor :pwd, :input
  
  def os
    name = ssh "lsb_release -d"
    dist = ssh "lsb_release -i"
    name.remove!("Description:")
    dist.remove!("Distributor ID:")
    {name: name, dist: dist}
  end
  
  def restart
    sudo_ssh "reboot"
  end
  
  def restart_apache
    sudo_ssh "apache2ctl restart"
  end
  
  def apache_config(config=nil)
    command = config ? "printf #{config.shell} | sudo tee /etc/apache2/apache2.conf" : "cat /etc/apache2/apache2.conf"
    sudo_ssh command
  end
  
  def status
    server ? true : false
  rescue
  end
  
  private
  def server
    Net::SSH.start(address, user)
  end
  
  def ssh(command)
    server.exec! command
  rescue => e
    e.message
  end
  
  def sudo_ssh(command)
    ssh "echo '#{pwd}' | sudo -S #{command}"
  end
end