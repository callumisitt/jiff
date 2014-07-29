class Server < ActiveRecord::Base
  require 'net/ssh'
  
  has_many :sites
  
  def os
    os = ssh "lsb_release -d"
    os.remove("Description:")
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
end