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

end