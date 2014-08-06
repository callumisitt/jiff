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
  
  def reload_apache
    sudo_ssh "apache2ctl graceful"
  end
  
  def restart_apache
    sudo_ssh "apache2ctl restart"
  end
    
  def apache_config(config=nil)
    file "/etc/apache2/apache2.conf", config
  end
  
  def info
    info = ssh "landscape-sysinfo"
    info = info.split(/\n/)
    info = info.map { |line|
      line.gsub!(/(\s[A-Z])/, '$$' + '\1')
      line.split('$$').map(&:strip).compact.reject(&:blank?)
    }
    info.pop(2)
    info.compact.reject(&:blank?).flatten
  end
  
  def file(file, contents=nil)
    command = contents ? "printf #{contents.shell} | sudo tee #{file}" : "cat #{file}"
    sudo_ssh command
  end
  
  def status
    server ? 2 : 9
  rescue
    return 9
  end
  
  def ssh(command)
    server.exec! command
  rescue => e
    e.message
  end
  
  def sudo_ssh(command)
    ssh "echo '#{pwd}' | sudo -S #{command}"
  end
  
  private
  def server
    Net::SSH.start(address, user)
  end
  
end