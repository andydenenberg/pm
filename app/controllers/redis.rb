#uri = URI.parse(ENV["REDISTOGO_URL"])
uri = URI.parse(ENV["REDIS_URL"])
REDIS = Redis.new(:url => uri)