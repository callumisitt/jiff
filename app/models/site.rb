class Site < ActiveRecord::Base
  belongs_to :server
  
  delegate :ssh, :sudo_ssh, :file, to: :server
  
  def view_log
    file "~/#{server_ref}/current/log/staging.log"
  end
  
  def virtual_host_config(config=nil)
    file "/etc/apache2/sites-available/#{server_ref}.conf", config
  end
  
  def enabled?
    enabled = ssh "ls /etc/apache2/sites-enabled"
    enabled.try(:include?, "#{server_ref}.conf")
  end
  
  def toggle(state)
    command = state == 1 ? "a2ensite #{server_ref}" : "a2dissite #{server_ref}"
    sudo_ssh command
    server.reload_apache
  end
  
  def online
    Rails.cache.fetch("online_#{id}", expires_in: 300) { online! }
  end
  
  def online!
    uptime = Api::UptimeRobot.new site: self
    uptime.site[0]['status'].to_i unless uptime.site.empty?
  end
end