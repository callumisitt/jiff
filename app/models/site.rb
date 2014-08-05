class Site < ActiveRecord::Base
  belongs_to :server
  
  delegate :ssh, :sudo_ssh, :file, to: :server
  
  def view_log
    file "~/#{server_ref}/current/log/staging.log"
  end
  
  def virtual_host_config(config=nil)
    file "/etc/apache2/sites-available/#{server_ref}.conf", config
  end
end