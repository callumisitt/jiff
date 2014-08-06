class SiteController < ApplicationController
  before_action :get_site, if: ->{params[:id]}

  def index
    @sites = Site.all
    @server = Server.find(params[:server_id])
  end
  
  def show
  end
  
  def toggle
    state = params[:site][:toggle].to_i if params[:site]
    state ||= 0
    @site.toggle state
    render nothing: true
  end
  
  def view_log
  end
  
  def virtual_host_config
    @site.virtual_host_config(params[:site][:input]) if params[:site]
  end
  
  private
  def get_site
    @site = Site.find(params[:id])
    @server = @site.server
  end
end