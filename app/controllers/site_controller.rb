class SiteController < ApplicationController
  before_action :site_init, if: -> { params[:id] }
  before_action -> { authenticate_sudo params[:site].try(:fetch, :password, nil) }, only: [:toggle, :virtual_host_config]

  def index
    @server = Server.find(params[:server_id])
    @sites = @server.sites
    @current_server = ServerPresenter.new(@server, request)
  end
  
  def command
    @site.send(params[:command])
    redirect_to server_site_path(@site.server, @site)
  end
  
  def toggle
    if @password
      state = params[:site][:toggle].to_i if submission?
      state ||= 0
      @site.toggle state
    else
      false
    end
  end
  
  def view_log
    @site.view_log if params[:site]
  end
  
  def virtual_host_config
    @site.virtual_host_config(params[:site][:input]) if submission?
  end
  
  def rake_task
    @site.rake(params[:site][:input]) if params[:site]
  end
  
  def show; end
  
  private
  
  def site_init
    @site = Site.find(params[:id])
    @server = @site.server
    @current_site = SitePresenter.new(@site, @server)
  end
  
  def submission?
    params[:site] && @password
  end
end