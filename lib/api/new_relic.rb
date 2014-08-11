module Api
  class NewRelic < Base
    base_uri 'api.newrelic.com:443/v2'
    
    def initialize(*args)
      super
      @options = { headers: { 'X-Api-Key' => Rails.application.secrets.new_relic } }
    end
    
    def applications
      get('/applications.json', @options)
    end
    
    def application
      @options.merge!(query: { 'filter[name]' => @site.new_relic_name })
      get('/applications.json', @options)
    end
    
    def server
      @options.merge!(query: { 'filter[name]' => @server.hostname.strip })
      get('/servers.json', @options)
    end
  end
end