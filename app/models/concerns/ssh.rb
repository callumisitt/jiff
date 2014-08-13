module SSH
  extend ActiveSupport::Concern

  included do
    require 'sshkit/dsl'
    
    attr_accessor :pwd, :input, :output
  end
  
  def file(file, contents = nil)
    if contents
      sudo_ssh { execute "printf #{contents.shell} | sudo tee #{file}", sanitize: false }
    else
      sudo_ssh { capture "cat #{file}" }
    end
  end
  
  def sudo_ssh(command = nil, &block)
    ssh do
      as :root do
        block_given? ? instance_eval(&block) : execute(command)
      end
    end
  end
  
  def send_message(message)
    puts message
    $redis.publish("server_#{address}.output", message.to_json)
  end
  
  def ssh(server, site = nil, options = { output: true }, &block)
    command = nil
    on "#{user}@#{address}" do
      with server: server.id do
        @server = server
        @site = site
        command = instance_eval &block
        @server.send_message(command) if options[:output]
      end
    end
    command
  end
end