class ApplicationController < ActionController::API

	include ActionController::HttpAuthentication::Token::ControllerMethods
	include Errors
	include Pundit

	
	before_action :send_push_notification

	# set default response format to json
	before_filter :set_default_response_format

	# capture all errors and pass them to functin render_error
	rescue_from GampError, :with => :render_error

	# capture all syntax errors
	rescue_from SyntaxError, :with => :handle_500

	# capture all general errors
	rescue_from StandardError, :with => :handle_general_error

	# rescue from authorized exception
	rescue_from Pundit::NotAuthorizedError, :with => :permission_denied

	# handle routing error and raise a routing exception
	def handle_404
		raise RoutingError.new(params[:path])
	end

	# private methods
	protected

	# params should be skipped in condition query
	def params_to_skip 
		[:apitoken]
	end


	# build mongoid query
	# 1. id=123,,345,,678  ===> id in [123, 345, 678]
	# 2. created=<=1023456 ===> created <= 1023456  
	def query_by_conditions(scope, query_parameters)
		tempResult = scope
		sortBy = query_parameters[:sortBy]
		query_parameters.except!(:sortBy).each do |key, value|
			field = key.to_sym

			if value.start_with? '<='
				tempResult = tempResult.lte(field => value[2..-1])
			elsif value.start_with? '<'
				tempResult = tempResult.lt(field => value[1..-1])
			elsif value.start_with? '>='
				tempResult = tempResult.gte(field => value[2..-1])
			elsif value.start_with? '>'
				tempResult = tempResult.gt(field => value[1..-1])
			elsif value.start_with? '!='
				tempResult = tempResult.nin(field => value[2..-1].split(',,'))
			else
				tempResult = tempResult.in(field => value.split(',,'))
			end	
		end

		if sortBy.present? 
			order_by_params = sortBy.split(',,').map do |item|
				if item.start_with? '-'
					[item[1..-1].to_sym, -1]
				else
					[item.to_sym, 1]
				end
			end
			return tempResult.all.order_by(order_by_params)
		else
			return tempResult.all
		end
	end

	def send_push_notification
		id = ['APA91bHrponxNLyTSmtBfmTaN_Itbne8IL2SuKw3w998-xPx4zHZ5bapk2Z0aZQdaD_qIdaovyXH-kYgnVg3kTGNNbCiDAqOGKhpExyQT7BDdI_TUEXq-F6zsZbFELujpj7bAjLeiF_nt2tqLfpRbXijMgbTEqDgFw']
		response = GCM.get.send(id, {
			data: { message: 'Hi, Teepan. is it still working' }
		})
		puts response.to_yaml
	end

	def restrict_access
		@session = Session.find_by(access_token: loads_apikey)

		# raise an unauthorized error if no session created or session expired
		raise UnauthenticatedError.new unless not @session.nil? and not @session.expire?

		# otherwise refresh seesion and retrive the user
		@session.refresh
		@current_user = @session.user

	end

	# get the apitoken from the request
	def loads_apikey
		@apitoken = params[:apitoken]
	end

	# render errors
	def render_error(error)
		render :json => error, :status => error.status
	end

	# get current user
	# create a guest if no user is found
	def current_user
		puts 'get current user'
		puts @current_user.id
		puts @current_user.name
		@current_user ||= User.new
	end

	# handle syntax errors and response with 500 status message
	def handle_500(error)
		render_error(InternalError.new(error.message))
	end

	# if permission denied, send a noauthorized error with code 403
	def permission_denied(error)
		render_error(NotauthorizedError.new)
	end

	# handle general error
	def handle_general_error(error)
		puts error.to_yaml
		render_error(InternalError.new(error.message));
	end

	# bind role 'moderator' to target
	def moderatorize(user, target)
		user.add_role :moderator, target
	end

	def set_default_response_format
		request.format = :json
	end

end
