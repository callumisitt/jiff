class ServerController < ApplicationController
  include ActionController::Live
  
  before_action :get_server, if: ->{params[:id]}

  def show
  end
  
  def apache_config
    @server.apache_config(params[:server][:input]) if params[:server]
  end
  
  def command
    @server.send(params[:command])
    redirect_to server_path(@server)
  end
  
  def output
    setup_stream
    @redis.subscribe('server.output') do |on|
      on.message do |event, data|
        response.stream.write("event: #{event}\n")
        response.stream.write("data: #{data}\n\n")
      end
    end
  rescue IOError
    logger.info "Closed stream"
  ensure
    @redis.quit
    response.stream.close
  end
  
  private
  def get_server
    @server = Server.find(params[:id])
  end
  
  def setup_stream
    response.headers['Content-Type'] = 'text/event-stream'
    @redis = Redis.new
  end
end