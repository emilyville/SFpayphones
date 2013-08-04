class BackgroundCaller
	@queue = :make_call
	def perform root_callsid
		pay_phones = $redis.hgetall "#{root_callsid}-outgoing"
		logger.info "starting calls"
		pay_phones.keys.each do |payphone|
			begin
				call = $twilio.account.calls.create(
					:From => '+14155086687',
					:To => payphone,
					:Url => url_for(controller: 'callbox', action: 'call_connected'),
					:StatusCallback => url_for(controller: 'callbox', action: 'call_completed')
					)
			rescue Exception => e
				logger.info "Unable to initiate call to #{payphone}: #{e.message}"
			end
			$redis.hset "#{root_callsid}-outgoing", call.to, call.sid
			$redis.set "#{call.sid}-root", root_callsid
			$redis.hsetnx "phonestatus", call.to, "ringing"
			$redis.expire "phonestatus", 180
			$redis.publish "callsupdated", JSON.dump({:status => "ringing"})
		end
	end
end