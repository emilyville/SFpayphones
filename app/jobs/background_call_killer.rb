class BackgroundCallKiller
	@queue = :kill_calls

	def self.perform call_sids
		call_sids.each do |sid|
			begin
				call = $twilio.account.calls.get(sid)
				call.hangup
				# delete the key for this call
				$redis.del "#{sid}-root"
			rescue Exception => e
				Resque.logger.debug "Encoutered error hanging up call #{sid}: #{e.message}"
			end
		end
	end
		end
	end
end