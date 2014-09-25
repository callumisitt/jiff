class Site < ActiveRecord::Base
  include SSH
  
  belongs_to :server
  
  delegate :user, :address, to: :server
  
  default_scope -> { order(:name) }
  
  attr_reader :password
  
  COMMANDS = %w[restart]
  
  def rake(task)
    ssh options = { output: true } do
      within "~/#{@site.server_ref}/current" do
        execute :rake, task
      end
    end
  end
  
  def view_log
    log_file "~/#{server_ref}/current/log/#{server.environment}.log", false
  end
  
  def virtual_host_config(content = nil)
    config = file "/etc/apache2/sites-available/#{server_ref}*", content
    server.reload_apache if content
    config
  end
  
  # commands
   
  def toggle(state)
    command = state == 1 ? :a2ensite : :a2dissite
    sudo_ssh { execute command, @site.server_ref }
    server.reload_apache
  end
  
  def restart
    ssh do
      within "#{@site.server_ref}/current/tmp" do
        execute :touch, 'restart.txt'
      end
    end
  end
  
  # general
  
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
  
  def enabled?
    enabled = ssh { capture :ls, '/etc/apache2/sites-enabled' }
    enabled.try(:include?, "#{server_ref}")
  end
  
  def pwd_not_needed
    true unless server.password_digest
  end
  
  def ssh(options = { }, &block)
    super(server, self, options)
  end
  
  private
  
  def uptime_robot
    Rails.cache.fetch("uptime_#{id}", expires_in: 300) { Api::UptimeRobot.new(site: self).site[0] }
  end
  
  def github
    Rails.cache.fetch("github_#{id}", expires_in: 600) { Api::GitHub.new site: self }
  end
end