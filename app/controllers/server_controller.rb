class ServerController < ApplicationController
  include ActionController::Live
  
  newrelic_ignore only: [:output]
  
  before_action :server, except: [:output], if: -> { params[:id] }
  before_action :authenticate_sudo, only: [:apache_config]

  def show
    view_type = params[:view_type].to_sym if ['dashboard', 'sidebar'].include? params[:view_type]
    
    respond_to do |format|
      format.js { render partial: 'server_item', locals: { view_type: params[:view_type].to_sym, server: @server }, layout: false }
      format.all { redirect_to server_site_index_path(@server) }
    end
  end
  
  def apache_config
    @server.apache_config(params[:server][:input]) if params[:server] && @sudo_password
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
    response.stream.close
  end
  
  private
  
  def server
    @server = Server.find(params[:id])
    @status = @server.status
  end
  
  def authenticate_sudo
    if params[:server] && @server.authenticate(params[:server][:password])
      @server.pwd = params[:server][:password]
      @sudo_password = true
    elsif @server.password_digest.nil?
      @sudo_password = true
      @pwd_not_needed = true
    else
      @sudo_password = false
    end
  end
  
  def stream_setup
    response.headers['Content-Type'] = 'text/event-stream'
    @redis = Redis.new
  end
  
  def stream_subscribe
    @redis.subscribe("server_#{params[:id]}.output") do |on|
      on.message do |event, data|
        response.stream.write("event: #{event}\n")
        response.stream.write("data: #{data}\n\n")
      end
    end
  end
end