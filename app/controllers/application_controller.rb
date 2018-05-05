class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  @ironcache = IronCache::Client.new
  @cache = @ironcache.cache("my_cache")
  @pr_time = Time.parse(@cache.get("poll_request_time").value)
  
end
