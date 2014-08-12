class Site < ActiveRecord::Base
  include SSH
  
  belongs_to :server
  
  delegate :server_id, :user, :address, to: :server
  
  def enabled?
    enabled = ssh 'ls /etc/apache2/sites-enabled'
    enabled.try(:include?, "#{server_ref}.conf")
  end
  
  def toggle(state)
    command = state == 1 ? "a2ensite #{server_ref}" : "a2dissite #{server_ref}"
    sudo_ssh command
    server.reload_apache
  end
  
  def restart
    ssh "cd #{server_ref}/current/tmp && touch restart.txt"
  end
  
  def rake(task)
    ssh "cd #{server_ref}/current && RAILS_ENV=#{server.environment} bundle exec rake #{task}"
  end
  
  def view_log
    file "~/#{server_ref}/current/log/#{server.environment}.log"
  end
  
  def virtual_host_config(config = nil)
    file "/etc/apache2/sites-available/#{server_ref}.conf", config
  end
  
  def server_response
    http = Net::HTTP.new(url.remove('http://'))
    site = Net::HTTP::Get.new('/')
    http.request(site).response.to_hash
  end
  
  def uptime(info)
    uptime_robot[info.to_s] if uptime_robot
  end
  
  def latest_commit
    github.latest_commit
  end
  
  private
  
  def uptime_robot
    Rails.cache.fetch("uptime_#{id}", expires_in: 300) { uptime_robot! }
  end
  
  def uptime_robot!
    uptime_robot = Api::UptimeRobot.new site: self
    uptime_robot.site[0]
  end
  
  def github
    Rails.cache.fetch("github_#{id}", expires_in: 600) { github! }
  end
  
  def github!
    Api::GitHub.new site: self
  end
end