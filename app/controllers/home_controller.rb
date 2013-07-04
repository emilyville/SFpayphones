class HomeController < ApplicationController
	def index
	end
	def index
		@phone_numbers = PhoneNumber.all
	end
end