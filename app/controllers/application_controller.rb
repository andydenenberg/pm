class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :poll_request #, except: [:create, :update, :destroy]
  
  def poll_request
    ironcache = IronCache::Client.new 
    @cache = ironcache.cache("my_cache")  
  end
  
end
