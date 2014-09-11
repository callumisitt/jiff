$redis = Redis.new

heartbeat_thread = Thread.new do
  while true
    $redis.publish('heartbeat', '%HB%')
    sleep 10.seconds
  end
end

at_exit do
  heartbeat_thread.kill
  $redis.quit
end