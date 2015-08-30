class MobileController < ApplicationController

	before_action :get_version, only: [:app]

	def base_version
		'1.0.8'
	end

	def get_version
		params[:app_version] || base_version
	end

	# GET /app
	def app

		if request.user_agent.include? 'iPhone'
			
			redirect_to "/app/#{ get_version }/ios/www/index.html"
		
		elsif request.user_agent.include? 'Android'
			
			redirect_to "/app/#{ get_version }/android/www/index.html"
		
		else
			redirect_to "/404.html"
		end

	end

end