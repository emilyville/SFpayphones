class PhoneNumberController < ApplicationController
	def index
		@phone_numbers = PhoneNumber.all
	end
end
