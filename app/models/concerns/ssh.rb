module SSH
  extend ActiveSupport::Concern

  included do
    require 'sshkit/dsl'
    
    attr_accessor :pwd, :input, :output
  end
  
  def file(file, content = nil)
    if content
      sudo_ssh { execute "printf #{content.shell} | sudo tee #{file}", sanitize: false }
    else
      sudo_ssh { capture :cat, file }
    end
  end

  def log_file(file, sudo = true)
    options = { output: true }
    method = sudo ? 'sudo_ssh' : 'ssh'
    self.send(method, options) { capture :tail, '-f', '-n', '250', file }
  end
  
  def sudo_ssh(options = { }, &block)
    ssh options = options do
      as :root do
        instance_eval &block
      end
    end
  end
  
  def ssh(server, site, options, &block)
  	options.merge! server: server.id
    command = nil
    on "#{user}@#{address}" do
      with rails_env: server.environment, path: server.environment_paths do
        @server = server
        @site = site
        @options = options
        command = instance_eval &block
      end
    end
    command
  end
end