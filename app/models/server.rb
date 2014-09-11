class Server < ActiveRecord::Base
  include SSH
    
  has_many :sites
  
  has_secure_password validations: false

  attr_reader :log
  
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

  def logs(directory = '/var/log/', log_files = [])
  	files = sudo_ssh { capture :ls, '-F', '-1', directory }
  	files = files.split(/\n/).map! { |file| "#{directory}#{file}" }
  	files.each do |log|
  		logs(log, log_files) if log.match /\/\z/
  	end
  	log_files.concat(files).reject! { |log| log =~ /\.\d/ || log.match(/\/\z/) }
  	log_files.sort_by(&:downcase)
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
    
  def apache_config(content = nil)
    config = file '/etc/apache2/apache2.conf', content
    reload_apache if content
    config
  end
  
  # general
  
  def status
  	# using same status codes as Uptime Robot for consistency
    hostname ? 2 : 9
  rescue
    return 9
  end
  
  def to_s
    name
  end
  
  def ssh(options = { }, &block)
    super(self, nil, options)
  end

  private
  
  def new_relic
    Rails.cache.fetch("new_relic_#{id}", expires_in: 300) { Api::NewRelic.new server: self }
  end
  
end