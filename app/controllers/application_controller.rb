class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
    
  private

  def logged_in?
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :logged_in?
  
  
#  before_action :poll_request #, except: [:create, :update, :destroy]
#  
#  def poll_request
#    ironcache = IronCache::Client.new 
#    cache = ironcache.cache("my_cache")
#    @poll_request_time = Time.parse(cache.get("poll_request_time").value) #+5.hours
#  end
  
end
