class ServerOutputFormatter < SSHKit::Formatter::Abstract
  def write(obj)
    return if obj.verbosity < SSHKit.config.output_verbosity
    case obj
    when SSHKit::Command    then write_command(obj)
    when SSHKit::LogMessage then write_log_message(obj)
    else
      original_output << "Output formatter doesn't know how to handle #{obj.class}\n"
    end
  end
  alias :<< :write

  private

  def write_command(command)
    unless command.started?
      original_output << "Running #{String(command)} on #{command.host.to_s}\n"
      original_output << "Command: #{command.to_command}" + "\n"
    end
            
    unless command.stdout.empty?
      command.stdout.lines.each do |line|
        line += "\n" unless line[-1] == "\n"
        original_output << line
        send_message line, command.options[:env][:server]
      end
    end

    if command.finished?
      message = "Finished in #{sprintf('%5.3f seconds', command.runtime)} with exit status #{command.exit_status} (#{ command.failure? ? 'failed' : 'successful' }).\n"
      original_output << message
      send_message message, command.options[:env][:server]
    end
  end

  def write_log_message(log_message)
    original_output << log_message.to_s + "\n"
  end
  
  def send_message(message, server_id)
    $redis.publish("server_#{server_id}.output", message.to_json)
  end
end

module SSHKit
  class Command
    alias_method :orig_sanitize, :sanitize_command!
    
    def sanitize_command!
      orig_sanitize unless options[:sanitize] == false
    end
  end
end

SSHKit.config.command_map.prefix[:rake].push('bundle exec')
SSHKit.config.output = ServerOutputFormatter.new($stdout)