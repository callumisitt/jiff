class Site < ActiveRecord::Base
  include SSH
  
  belongs_to :server
  
  delegate :user, :address, to: :server
  
  def enabled?
    enabled = ssh { capture :ls, '/etc/apache2/sites-enabled' }
    enabled.try(:include?, "#{server_ref}.conf")
  end
  
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
  
  def rake(task)
    ssh output: false do
      within "~/#{@site.server_ref}/current" do
        with rails_env: @server.environment, path: '~/.rbenv/shims' do
          execute :rake, task
        end
      end
    end
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
  
  def ssh(*args, &block)
    super(server, self)
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