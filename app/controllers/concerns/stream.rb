module Stream
  extend ActiveSupport::Concern
  include ActionController::Live
  
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
  
  def stream_setup
    response.headers['Content-Type'] = 'text/event-stream'
    @redis = Redis.new
    @sse = SSE.new(response.stream)
  end
  
  def stream_subscribe
    @redis.subscribe(["server_#{params[:id]}.output", 'heartbeat']) do |on|
      on.message do |event, data|
        if event == 'heartbeat'
          @sse.write(1, event: event)
        else
          @sse.write(data, event: event)
        end
      end
    end
  end
end