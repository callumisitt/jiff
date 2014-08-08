class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :authenticate_admin_user!
  before_action :set_defaults
  
  private
  
  def set_defaults
    @servers = Server.all
  end
end