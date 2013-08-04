Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }
uri = URI.parse(ENV["REDISCLOUD_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port)