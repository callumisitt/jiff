module Api
  class GitHub < Base
    base_uri 'api.github.com:443'
    
    def initialize(*args)
      super
      @options = { headers: { 'Authorization' => "token #{Rails.application.secrets.github}", 'user-agent' => 'Ruby on Rails' } }
    end
    
    def repos
      get('/user/repos', @options)
    end
    
    def repo
      get("/repos/WhiteAgency/#{@site.repo}", @options)
    end
    
    def latest_commit
      commit = get("/repos/WhiteAgency/#{@site.repo}/commits", @options)
      commit.response.code.to_i == 200 ? commit.first : nil
    end
  end
end