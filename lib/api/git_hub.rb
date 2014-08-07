module Api
  class GitHub < Base
    base_uri 'api.github.com:443'
    
    def initialize(*args)
      super
      @options = {headers: { "Authorization" => "token #{ENV['GITHUB']}", "user-agent" => "Ruby on Rails" }}
    end
    
    def repos
      get('/user/repos', @options)
    end
    
    def repo
      get("/repos/WhiteAgency/#{@site.repo}", @options)
    end
    
    def latest_commit
      get("/repos/WhiteAgency/#{@site.repo}/commits", @options).first
    end
  end
end