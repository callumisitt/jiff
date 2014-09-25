class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  rescue_from SSHKit::Runner::ExecuteError, with: ->(exception) { ssh_error(exception) }
  
  before_action :authenticate_admin_user!
  before_action :init

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

  def init
    @servers = Server.all
    @parent_path = case params[:controller]
    when 'server'
      server_path(params[:id])
    when 'site'
      params[:id] ? server_site_path(params[:server_id], params[:id]) : server_site_index_path(params[:server_id])
    else
      root_path unless params[:controller] == 'rails_admin/main'
    end
  end
  
  def ssh_error(exception)
    message = 'Unfortunately, there was an error.' if exception.to_s.include? 'stderr: Nothing written'
    message ||= exception.to_s.lines.last
    puts message
    flash.now[:alert] = message
    render params[:action]
  rescue
    redirect_to @parent_path, alert: message
  end
end