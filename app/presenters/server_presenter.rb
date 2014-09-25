class ServerPresenter
  def initialize(server, request)
    @server = server
    @request = request
  end
  
  def view_width
    URI(@request.referer).path == '/' ? 6 : 12
  end
  
  def sudo
    @server.pwd_not_needed ? nil : "data-sudo=#{@server.id}"
  end
  
  def commands
    Server::COMMANDS
  end
end