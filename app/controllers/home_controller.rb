class HomeController < ApplicationController
	def index
		@phone_numbers = PhoneNumber.all
	end
end