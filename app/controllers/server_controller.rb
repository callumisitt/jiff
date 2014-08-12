class ServerController < ApplicationController
  include ActionController::Live
  
  newrelic_ignore only: [:output]
  
  before_action :server, if: -> { params[:id] && params[:action] != 'output' }

  def show
    return render partial: 'server_item', locals: { view_type: params[:view_type].to_sym, server: @server }, layout: false if request.xhr?
    redirect_to server_site_index_path(@server)
  end
  
  def apache_config
    @server.apache_config(params[:server][:input]) if params[:server]
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
    @monitor = @server.monitor['summary']
    @status = @server.status
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