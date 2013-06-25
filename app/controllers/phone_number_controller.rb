class PhoneNumberController < ApplicationController
	def index
		@phone_numbers = PhoneNumber.all
	end

	def clear
		PhoneNumber.delete_all
		redirect_to :action => "index"
	end

end
