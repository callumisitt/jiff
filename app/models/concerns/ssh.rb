module SSH
  extend ActiveSupport::Concern

  included do
    require 'net/ssh'
    
    attr_accessor :pwd, :input, :output
  end
  
  def file(file, contents = nil)
    command = contents ? "printf #{contents.shell} | sudo tee #{file}" : "cat #{file}"
    sudo_ssh command
  end
  
  def ssh(command)
    start command
  rescue => e
    e.message
  end
  
  def sudo_ssh(command)
    ssh "echo '#{pwd}' | sudo -S #{command}"
  end
  
  def send_message(message)
    puts message
    $redis.publish("server_#{server_id}.output", message.to_json)
  end

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
  
  def start(command = nil)
    @response = ''
    Net::SSH.start(address, user) do |ssh|
      channel = ssh.open_channel do |_ch|
        exec(channel, command)
      end
      channel.wait
      @response
    end
  end

end