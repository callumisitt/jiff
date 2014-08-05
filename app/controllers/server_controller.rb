class ServerController < ApplicationController
  before_action :get_server, if: ->{params[:id]}

  def show
  end
  
  def apache_config
    @server.apache_config(params[:server][:input]) if params[:server]
  end
  
  def command
    @server.send(params[:command])
    render nothing: true
  end
  
  private
  def get_server
    @server = Server.find(params[:id])
  end
  
end