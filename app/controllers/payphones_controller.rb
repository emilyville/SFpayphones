class PayphonesController < ApplicationController
	def payphones
		respond_to do |format|
			format.json {render :partial => "payphones/payphones.json"}
		end
	end

	def sanfrancisco
		respond_to do |format|
			format.json {render :partial => "payphones/sanfrancisco.json"}
		end
	end
end