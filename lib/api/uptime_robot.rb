module Api
  class UptimeRobot < Base
    base_uri 'api.uptimerobot.com'
    
    def initialize(*args)
      super
      @options = { apiKey: Rails.application.secrets.uptime_robot, format: 'json', noJsonCallback: 1 }
    end
    
    def monitors
      get('/getMonitors', query: @options)
    end
    
    def site
      monitors['monitors']['monitor'].select { |site| site['url'] == @site.url }
    end
  end
end