class ServerPresenter
  def initialize(server, request)
    @server = server
    @request = request
  end
  
  def view_width
    URI(@request.referer).path == '/' ? 6 : 12
  end
  
  def pwd_not_needed
    true unless @server.password_digest
  end
  
  def commands
    Server::COMMANDS
  end
end