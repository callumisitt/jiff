class SiteController < ApplicationController
  before_action :site, if: -> { params[:id] }
  before_action -> { authenticate_sudo params.fetch(:server, {}).fetch(:password, nil) }, only: [:toggle, :virtual_host_config]

  def index
    @server = Server.find(params[:server_id])
    @sites = @server.sites
  end
  
  def show; end
  
  def command
    @site.send(params[:command])
    redirect_to server_site_path(@site.server, @site)
  end
  
  def toggle
    if @sudo_password
      state = params[:site][:toggle].to_i if params[:site]
      state ||= 0
      @site.toggle state
    end
    render nothing: true
  end
  
  def view_log
  	@site.view_log if params[:site]
  end
  
  def virtual_host_config
    @site.virtual_host_config(params[:site][:input]) if params[:site] && @sudo_password
  end
  
  def rake_task
    @site.rake(params[:site][:input]) if params[:site]
  end
  
  private
  
  def site
    @site = Site.find(params[:id])
    @online_status = @site.uptime(:status).to_i
    @latest_commit = @site.latest_commit
    @server = @site.server
  end
end