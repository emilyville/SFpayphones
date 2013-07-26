require 'twilio-ruby'
require 'json'

class CallboxController < ApplicationController
	def incoming_sms
		#get number from sms
		number = params[:From]
		body = params[:Body]
		logger.debug "Received body #{body}"
		pay_phones = PayPhone.where(neighborhood: body)
		if pay_phones.empty?
			no_phones number and return
		end
		number_of_phones pay_phones, body, number
	end

	def no_phones to
		response = Twilio::TwiML::Response.new do |r|
			r.Sms "Sorry, I don't know any phones in that neighborhood.", :to => to,
				:from => '+14155086687'
		end
		render :xml => response.text
	end

	def number_of_phones pay_phones, neighborhood, to
		response = Twilio::TwiML::Response.new do |r|
			r.Sms "I know #{pay_phones.length} in #{neighborhood}", :to => to,
				:from => '+14155086687'
		end
		call_phones pay_phones, to
		render :xml => response.text
	end

	def call_phones pay_phones, caller
		begin
			main_call = $twilio.account.calls.create(
				:From => '+14155086687',
				:To => caller,
				:Url => url_for(controller: 'callbox', action: 'caller_connected'),
				:StatusCallback => url_for(controller: 'callbox', action: 'caller_completed')
			)
			$redis.multi do
				pay_phones.each do |payphone|
					$redis.hset "#{main_call.sid}-outgoing", payphone.number, ""
				end
			end
		rescue Exception => e
			logger.info "Caught exception while initiating call: #{e.message}"
			# Couldn't make the initial call to the user!
		end
	end

	def caller_connected
		root_callsid = params[:CallSid]
		pay_phones = $redis.hgetall "#{root_callsid}-outgoing"
		pay_phones.keys.each do |payphone|
			begin
				call = $twilio.account.calls.create(
					:From => '+14155086687',
					:To => payphone,
					:Url => url_for(controller: 'callbox', action: 'call_connected'),
					:StatusCallback => url_for(controller: 'callbox', action: 'call_completed')
					)
				$redis.hset "#{root_callsid}-outgoing", payphone.number, call.sid
				$redis.set "#{call.sid}-root", root_callsid
				$redis.hset "phonestatus", payphone, "ringing"
				$redis.publish "callsupdated", JSON.dump({:status => "ringing"})
			rescue Exception => e
				logger.info "Unable to initiate call to #{payphone.number}: #{e.message}"
			end
		end
		# put caller in queue
		begin
			queue = $twilio.client.queues.create(:friendly_name => root_callsid)
			$redis.set "#{root_callsid}-queue", queue.sid
		rescue
			# queue may already exist, but probably not
		end
		response = Twilio::TwiML::Response.new do |r|
			r.Say "Please wait while we connect you", voice: "alice"
			r.Enqueue "#{root_callsid}"
		end
		render :xml => response.text
	end

	def hangup_calls call_sids
		call_sids.each do |sid|
			begin
				call = $twilio.client.calls.get(sid)
				call.hangup
				# delete the key for this call
				$redis.del "#{sid}-root"
			rescue Exception => e
				logger.debug "Encoutered error hanging up call #{sid}: #{e.message}"
			end
		end
	end

	def caller_completed
		call_sid = params[:CallSid]
		#hangup all the calls
		all_calls = $redis.hgetall "#{call_sid}-outgoing"
		hangup_calls all_calls.values
		#lookup the queue sid
		queue_sid = $redis.get "#{call_sid}-queue"
		begin
			# delete the queue
			$twilio.account.queues.delete(queue_sid)
		rescue Exception => e
			logger.debug "Failed to delete queue #{queue_sid}: #{e.message}"
		end
		#delete all the redis keys
		$redis.del "#{call_sid}-connected"
	end

	def call_connected
		number = params[:To]
		caller = params[:Caller]
		call_sid = params[:CallSid]
		# get root call associated with this call
		root_callsid = $redis.get "#{call_sid}-root"
		# try to claim this call
		success = $redis.setnx "#{root_callsid}-connected", call_sid
		if success == 0
			# call is already connected, abort!!
			response = Twilio::TwiML::Response.new do |r|
				r.Hangup
			end
			render :xml => response.text and return
		end
		# we claimed the call!
		# hangup other calls
		all_callsids = $redis.hgetall("#{root_callsid}-outgoing").values
		all_callsids.delete call_sid
		hangup_calls all_callsids
		# create the response to connect to the waiting caller
		response = Twilio::TwiML::Response.new do |r|
			r.Dial do |d|
				d.Queue root_callsid
			end
		end
	end

	def call_completed
		number = params[:To]
		$redis.hdel "phonestatus", number, "completed"
		$redis.publish "callsupdated", JSON.dump({:status => "completed"})
	end
end