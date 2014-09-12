class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  rescue_from SSHKit::Runner::ExecuteError do |exception|
    message = 'Unfortunately, there was an error.' if exception.to_s.include? 'stderr: Nothing written'
    message ||= exception.to_s.lines.last
    flash.now[:alert] = message
    render params[:action]
  end
  
  before_action :authenticate_admin_user!
  before_action :set_defaults

  def authenticate_sudo(password)
    if password
     	if @server.authenticate(password)
	      @server.pwd = password
	      @sudo_password = true
	    else
        flash.delete(:alert)
        if request.format == :js
          flash.now[:alert] = 'Sorry, try again.'
          return false
        else
          flash[:alert] = 'Sorry, try again.'
        end
	    end
    elsif @server.password_digest.nil?
      @pwd_not_needed = true
    end
    
    @password = @sudo_password || @pwd_not_needed
  end
  
  private

  def set_defaults
    @servers = Server.all
  end
end