class SitePresenter
  def initialize(site, server)
    @site = site
    @server = server
  end
  
  def online_status
    @site.uptime(:status).to_i
  end
  
  def latest_commit
    @site.latest_commit
  end
  
  def commands
    Site::COMMANDS
  end
end