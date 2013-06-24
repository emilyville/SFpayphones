require 'rubygems'
require 'twilio-ruby'

#build up a response

class HelloWorldController < ApplicationController
	def index
		response = Twilio::TwiML::Response.new do |r|
  			r.Sms 'hello there', :to => '+14155290016', :from => '+14155086687'
  		end
  		render :xml => response.text
  	end
end
