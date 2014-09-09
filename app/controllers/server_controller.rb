class ServerController < ApplicationController
  include ActionController::Live
  
  newrelic_ignore only: [:output]
  
  before_action :server, except: [:output], if: -> { params[:id] }
  before_action -> { authenticate_sudo params.fetch(:server, {}).fetch(:password, nil) }, only: [:apache_config, :view_log]

  def show
    view_type = params[:view_type].to_sym if ['dashboard', 'sidebar'].include? params[:view_type]
    
    respond_to do |format|
      format.js { render partial: 'server_item', locals: { view_type: view_type, server: @server }, layout: false }
      format.all { redirect_to server_site_index_path(@server) }
    end
  end
  
  def apache_config
    @server.apache_config(params[:server][:input]) if params[:server] && @sudo_password
  end

  def view_log
  	if params[:server] && params[:server][:log]
	  	@file = params[:server][:log] 
	  	@server_log = @server.log_file(@file)
	  end
  end
  
  def status; end
  
  def command
    return unless Server::COMMANDS.include? params[:command]
    @server.send(params[:command])
    redirect_to server_path(@server)
  end
  
  def output
    stream_setup
    stream_subscribe
    render nothing: true
  rescue IOError
    logger.info 'Closed stream'
  ensure
    @redis.quit
    @sse.close
  end
  
  private
  
  def server
    @server = Server.find(params[:id])
    @status = @server.status
  end
  
  def stream_setup
    response.headers['Content-Type'] = 'text/event-stream'
    @redis = Redis.new
  end
  
  def stream_subscribe
    @sse = SSE.new(response.stream)
    @redis.subscribe("server_#{params[:id]}.output") do |on|
      on.message do |event, data|
        @sse.write(data, event: event)
      end
    end
  end
end