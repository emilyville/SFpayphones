require 'twilio-ruby'
require 'json'
require 'background_caller'
require 'background_call_killer'


class CallboxController < ApplicationController
	def incoming_sms
		#get number from sms
		number = params[:From]
		body = params[:Body]
		logger.debug "Received body #{body}"
		if body == 'All'
			pay_phones = PayPhone.all
		else
			pay_phones = PayPhone.where(neighborhood: body)
		end
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
					$redis.hset "locations", payphone.number, JSON.dump({'lat' => payphone.lat, 'lon' => payphone.lon})
					$redis.expire "locations", 180

				end
			end
		rescue Exception => e
			logger.info "Caught exception while initiating call: #{e.message}"
			# Couldn't make the initial call to the user!
		end
	end

	def caller_connected
		root_callsid = params[:CallSid]
		logger.info "scheduling background job to create calls"
		Resque.enqueue(BackgroundCaller, root_callsid,
			url_for(controller: 'callbox', action: 'call_connected'),
			url_for(controller: 'callbox', action: 'call_completed'))
		logger.info "adding caller to queue"
		# put caller in queue
		begin
			queue = $twilio.account.queues.create(:friendly_name => root_callsid)
			$redis.set "#{root_callsid}-queue", queue.sid
		rescue
			# queue may already exist, but probably not
		end
		response = Twilio::TwiML::Response.new do |r|
			r.Say "Please wait while we connect you", voice: "alice"
			r.Enqueue "#{root_callsid}"
		end
		logger.info "rendering response"
		render :xml => response.text
	end

	def caller_completed
		call_sid = params[:CallSid]
		#hangup all the calls
		all_calls = $redis.hgetall "#{call_sid}-outgoing"
		Resque.enqueue(BackgroundCallKiller, all_calls.values)
		#lookup the queue sid
		queue_sid = $redis.get "#{call_sid}-queue"
		begin
			# delete the queue
			queue = $twilio.account.queues.get queue_sid
			queue.delete
		rescue Exception => e
			logger.debug "Failed to delete queue #{queue_sid}: #{e.message}"
		end
		#delete all the redis keys
		$redis.del "#{call_sid}-connected"
		render :nothing => true
	end

	def call_connected
		number = params[:To]
		caller = params[:Caller]
		call_sid = params[:CallSid]
		logger.debug "call connected!"
		# get root call associated with this call
		root_callsid = $redis.get "#{call_sid}-root"
		# try to claim this call
		success = $redis.setnx "#{root_callsid}-connected", call_sid
		if success == 0
			logger.info "call already connected, hanging up"
			# call is already connected, abort!!
			response = Twilio::TwiML::Response.new do |r|
				r.Hangup
			end
			render :xml => response.text and return
		end
		# we claimed the call!
		# hangup other calls
		logger.info "hanging up other calls"
		all_callsids = $redis.hgetall("#{root_callsid}-outgoing").values
		all_callsids.delete call_sid
		Resque.enqueue(BackgroundCallKiller, all_callsids)
		# change live status
		$redis.hset "phonestatus", number, "connected"
		$redis.expire "phonestatus", 180
		logger.info "connecting to caller"
		# create the response to connect to the waiting caller
		response = Twilio::TwiML::Response.new do |r|
			r.Dial do |d|
				d.Queue root_callsid
			end
		end
		render :xml => response.text
	end

	def call_completed
		number = params[:To]
		begin
			$redis.hdel "phonestatus", number
			$redis.publish "callsupdated", JSON.dump({:status => "completed"})
		rescue Exception => e
			logger.info "error cleaning up call:#{number}, #{e.message}"
		end
		render :nothing => true
	end
end
