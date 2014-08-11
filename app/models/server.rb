class Server < ActiveRecord::Base
  require 'net/ssh'
    
  has_many :sites
  
  attr_accessor :pwd, :input, :output
  
  def os
    name = ssh 'lsb_release -d'
    dist = ssh 'lsb_release -i'
    name.remove!('Description:')
    dist.remove!('Distributor ID:')
    { name: name, dist: dist }
  end
  
  def ip
    ssh 'hostname -I'
  end
  
  def hostname
    ssh 'hostname'
  end
  
  def restart
    sudo_ssh 'reboot'
  end
  
  def reload_apache
    sudo_ssh 'apache2ctl graceful'
  end
  
  def restart_apache
    sudo_ssh 'apache2ctl restart'
  end
    
  def apache_config(config = nil)
    apache_config = file '/etc/apache2/apache2.conf', config
    reload_apache if config
    apache_config
  end
  
  def info
    info = ssh 'landscape-sysinfo'
    info = info.split(/\n/)
    info = info.map do |line|
      line.gsub!(/(\s[A-Z])/, '$$' + '\1')
      line.split('$$').map(&:strip).compact.reject(&:blank?)
    end
    info.pop(2)
    info.compact.reject(&:blank?).flatten
  end
  
  def file(file, contents = nil)
    command = contents ? "printf #{contents.shell} | sudo tee #{file}" : "cat #{file}"
    sudo_ssh command
  end
  
  def status
    server ? 2 : 9
  rescue
    return 9
  end
  
  def monitor
    new_relic.server['servers'][0]
  end
  
  def ssh(command)
    server command
  rescue => e
    e.message
  end
  
  def sudo_ssh(command)
    ssh "echo '#{pwd}' | sudo -S #{command}"
  end
  
  def send_message(message)
    puts message
    $redis.publish('server.output', message.to_json)
  end
  
  def to_s
    name
  end
  
  private
  
  def exec(ch, command)
    ch.exec 'bash -l' do |ch2, _success|
      ch2.send_data "#{command}\n"
      ch2.send_data "exit\n"
      ch2.on_data do |_ch3, data|
        send_message data
        @response.concat(data)
      end
    end
  end
  
  def server(command = nil)
    @response = ''
    Net::SSH.start(address, user) do |ssh|
      channel = ssh.open_channel do |_ch|
        exec(channel, command)
      end
      channel.wait
      @response
    end
  end
  
  def new_relic
    Rails.cache.fetch("new_relic_#{id}", expires_in: 300) { new_relic! }
  end
  
  def new_relic!
    Api::NewRelic.new server: self
  end
  
end