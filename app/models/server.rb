class Server < ActiveRecord::Base
  include SSH
    
  has_many :sites
  
  has_secure_password validations: false
  
  COMMANDS = %w[restart reload_apache restart_apache]
  
  # info
  
  def os
    name = ssh { capture :lsb_release, '-d' }
    dist = ssh { capture :lsb_release, '-i' }
    name.remove!('Description:')
    dist.remove!('Distributor ID:')
    { name: name.strip!, dist: dist.strip! }
  end
  
  def ip
    ssh { capture :hostname, '-I' }
  end
  
  def hostname
    ssh { capture :hostname }
  end
  
  def info
    info = ssh { capture 'landscape-sysinfo' }
    info = info.split(/\n/)
    info = info.map do |line|
      line.gsub!(/(\s[A-Z])/, '$$' + '\1')
      line.split('$$').map(&:strip).compact.reject(&:blank?)
    end
    info.pop(2)
    info.compact.reject(&:blank?).flatten
  end
  
  def monitor
    new_relic.server['servers'][0]
  end
  
  # commands
  
  def restart
    sudo_ssh { execute :reboot }
  end
  
  def reload_apache
    sudo_ssh { execute :service, 'apache2', 'graceful' }
  end
  
  def restart_apache
    sudo_ssh { execute :service, 'apache2', 'restart' }
  end
  
  # edits
    
  def apache_config(config = nil)
    apache_config = file '/etc/apache2/apache2.conf', config
    reload_apache if config
    apache_config
  end
  
  # general
  
  def status
    hostname ? 2 : 9
  rescue
    return 9
  end
  
  def to_s
    name
  end
  
  def ssh(*args, &block)
    super(self)
  end

  private
  
  def new_relic
    Rails.cache.fetch("new_relic_#{id}", expires_in: 300) { new_relic! }
  end
  
  def new_relic!
    Api::NewRelic.new server: self
  end
  
end