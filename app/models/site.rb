class Site < ActiveRecord::Base
  require 'net/http'
  
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
  
  def server_response
    http = Net::HTTP.new(url.remove('http://'))
    site = Net::HTTP::Get.new('/')
    http.request(site).response.to_hash
  end
  
  def online
    uptime['status'].to_i unless uptime.empty?
  end
  
  def avg_uptime
    uptime['alltimeuptimeratio'] unless uptime.empty?
  end
  
  def latest_commit
    github.latest_commit
  end
  
  private
  def uptime
    Rails.cache.fetch("uptime_#{id}", expires_in: 300) { uptime! }
  end
  
  def uptime!
    uptime = Api::UptimeRobot.new site: self
    uptime.site[0]
  end
  
  def github
    Rails.cache.fetch("github_#{id}", expires_in: 600) { github! }
  end
  
  def github!
    Api::GitHub.new site: self
  end
end