class SiteController < ApplicationController
  before_action :get_site, if: ->{params[:id]}

  def index
  end
  
  def show
  end
  
  private
  def get_site
    @site = Site.find(params[:id])
    @server = @site.server
  end
end