class ServerController < ApplicationController
  include ActionController::Live
  
  before_action :server, if: -> { params[:id] }

  def show; end
  
  def apache_config
    @server.apache_config(params[:server][:input]) if params[:server]
  end
  
  def command
    @server.send(params[:command])
    redirect_to server_path(@server)
  end
  
  def output
    stream_setup
    stream_subscribe
  rescue IOError
    logger.info 'Closed stream'
  ensure
    @redis.quit
    response.stream.close
  end
  
  private
  
  def server
    @server = Server.find(params[:id])
  end
  
  def stream_setup
    response.headers['Content-Type'] = 'text/event-stream'
    @redis = Redis.new
  end
  
  def stream_subscribe
    @redis.subscribe('server.output') do |on|
      on.message do |event, data|
        response.stream.write("event: #{event}\n")
        response.stream.write("data: #{data}\n\n")
      end
    end
  end
end