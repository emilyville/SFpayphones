# uri = URI.parse("redis://rediscloud:D2tfqczAyZTEBrBO@pub-redis-18334.us-east-1-4.2.ec2.garantiadata.com:18334")
$redis = Redis.new(:host => ENV["REDIS_HOST"], :port => ENV["REDIS_PORT"], :password => ENV["REDIS_PASSWORD"])
