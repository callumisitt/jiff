module Api
  class UptimeRobot < Base
    base_uri 'api.uptimerobot.com'
    
    def initialize(*args)
      super
      @options = {apiKey: 'u39676-48113158c4cbd0ecd845dcd8', format: 'json', noJsonCallback: 1}
    end
    
    def monitors
      get('/getMonitors', query: @options)
    end
    
    def site
      monitors['monitors']['monitor'].select {|site| site['url'] == @site.url}
    end
  end
end