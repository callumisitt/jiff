class Server < ActiveRecord::Base
  require 'net/ssh'
    
  has_many :sites
  
  attr_accessor :pwd, :input, :output
  
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
    reload_apache if config
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
    # set up proper status check
    2
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
  
  private
  def server(command)
    @response = ''
    Net::SSH.start(address, user) do |ssh|
     channel = ssh.open_channel do |ch|
        ch.exec "bash -l" do |ch2, success|
          ch2.send_data "export TERM=vt100\n"
          ch2.send_data "#{command}\n"
          ch2.send_data "exit\n"
          ch2.on_data do |ch3, data|
            send_message data
            @response += data
          end
        end
      end
      channel.wait
      @response
    end
  end
  
end