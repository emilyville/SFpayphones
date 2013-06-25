require 'rubygems'
require 'twilio-ruby'

#collect numbers by sms
class CallThemAllController < ApplicationController
	def incoming_sms
		#get number from sms
		number = params[:From]
		@phonenumber = PhoneNumber.new(:number => number)
		@phonenumber.save
		response = Twilio::TwiML::Response.new do |r|
  			r.Sms 'hello there', :to => number, :from => '+14155086687'
  		end
  		render :xml => response.text
	end

	def call 
		#get all phone numbers
		phone_numbers = PhoneNumber.all
		#call phone numbers
		client = Twilio::REST::Client.new(ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"])
		phone_numbers.each do |number|
			client.account.calls.create(
				:From => '+14155086687',
				:To => '+14155290016',
				:Url => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.rock'
				)
		end
	end
end
