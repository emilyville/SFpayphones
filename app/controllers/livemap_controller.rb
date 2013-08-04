require 'redis'
require 'reloader/sse'

class LivemapController < ApplicationController
  	include ActionController::Live
	def index
  		response.headers['Content-Type'] = 'text/event-stream'
    	sse = Reloader::SSE.new(response.stream)

    	begin
    	#	sse.write({ :message => 'starting messages' })
  	 		# $redis.subscribe('callevents') do |on|          
    		# 		on.message do |channel, msg|
    		# 			sse.write({ :number => 'number'})
      # 			end
    		# end
        while true do
          calls = $redis.hgetall('phonestatus')
          locations = $redis.hgetall('locations')
          message = []
          calls.each do |number, status|
            if locations[number]
              location = JSON.parse(locations[number])
              message << {'number' => number, 'status' => status, 'lat' => location['lat'], 'lon' => location['lon']}
            end
          end
          sse.write message
          sleep 2
        end
  		rescue IOError
  			# error on client disconnect
  		ensure
  			sse.close
		end
	end
end
