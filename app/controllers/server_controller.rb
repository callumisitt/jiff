class ServerController < ApplicationController
  include Stream
  
  before_action :server_init, except: [:output], if: -> { params[:id] }
  before_action -> { authenticate_sudo params[:server].try(:fetch, :password, nil) }, only: [:config_file, :view_log, :command]
  
  newrelic_ignore only: [:output]

  def show
    respond_to do |format|
      format.js { render partial: 'item', locals: { server: @server }, layout: false }
      format.all { redirect_to server_site_index_path(@server) }
    end
  end
  
  def config_file
    @file = params[:file]
    @server.config(@file, params[:server][:input]) if submission?
  end

  def view_log
    if submission? && params[:server][:log]
	    @file = params[:server][:log]
	  	@server_log = @server.log_file(@file)
	  end
  end
  
  def command
    @server.send(params[:command])
    render nothing: true
  end
  
  def status; end
  
  private
  
  def server_init
    @server = Server.find(params[:id])
    @current_server = ServerPresenter.new(@server, request)
  end
  
  def submission?
    params[:server] && @password
  end
end