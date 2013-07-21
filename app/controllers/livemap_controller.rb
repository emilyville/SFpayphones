require 'redis'
require 'reloader/sse'

class LivemapController < ApplicationController
  	include ActionController::Live
	def index
  		response.headers['Content-Type'] = 'text/event-stream'
    	sse = Reloader::SSE.new(response.stream)

    	begin
    		redis = Redis.new(:timeout => 0)
    		sse.write({ :message => 'starting messages' })
  	 		redis.subscribe('callevents') do |on|          
    				on.message do |channel, msg|
    					sse.write({ :number => 'number'})
      			end
    		end
  		rescue IOError
  			# error on client disconnect
  		ensure
  			sse.close
		end
	end
end
