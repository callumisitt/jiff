class SiteController < ApplicationController
  before_action :site, if: -> { params[:id] }
  before_action -> { authenticate_sudo params[:site].try(:fetch, :password, nil) }, only: [:toggle, :virtual_host_config]

  def index
    @server = Server.find(params[:server_id])
    @sites = @server.sites
    @pwd_not_needed = true unless @server.password_digest
  end
  
  def command
    @site.send(params[:command])
    redirect_to server_site_path(@site.server, @site)
  end
  
  def toggle
    if @password
      state = params[:site][:toggle].to_i if params[:site]
      state ||= 0
      @site.toggle state
    end
  end
  
  def view_log
  	@site.view_log if params[:site]
  end
  
  def virtual_host_config
    @site.virtual_host_config(params[:site][:input]) if params[:site] && @password
  end
  
  def rake_task
    @site.rake(params[:site][:input]) if params[:site]
  end
  
  def show; end
  
  private
  
  def site
    @site = Site.find(params[:id])
    @online_status = @site.uptime(:status).to_i
    @latest_commit = @site.latest_commit
    @server = @site.server
  end
end