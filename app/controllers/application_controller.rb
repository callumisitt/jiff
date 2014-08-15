class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :authenticate_admin_user!
  before_action :set_defaults

  def authenticate_sudo(password)
  	flash.delete(:error)

    if password
    	if @server.authenticate(password)
	      @server.pwd = password
	      return @sudo_password = true
	    else
	    	flash[:error] = 'Sorry, try again.'
	    end
    elsif @server.password_digest.nil?
      @pwd_not_needed = true
    end

    @sudo_password = false
  end
  
  private

  def set_defaults
    @servers = Server.all
  end
end