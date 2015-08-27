class ApplicationController < ActionController::Base

	include ActionController::HttpAuthentication::Token::ControllerMethods
	include Errors
	include Pundit

	
	before_action :get_geo_location, :load_loggedin_user

	# set default response format to json
	before_filter :set_default_response_format

	# capture all errors and pass them to functin render_error
	rescue_from GampError, :with => :render_error

	# capture all syntax errors
	rescue_from SyntaxError, :with => :handle_general_error

	# capture all general errors
	rescue_from StandardError, :with => :handle_general_error

	# rescue from authorized exception
	rescue_from Pundit::NotAuthorizedError, :with => :permission_denied

	# handle routing error and raise a routing exception
	def handle_404
		raise RoutingError.new(request.original_url)
	end

	# private methods
	protected

	def default_url_options
		if Rails.env.test? or Rails.env.production?
			{ :host => 'rails-api-env-b4cm2bfxbr.elasticbeanstalk.com' }
		else
			{}
		end
	end

	# get geo information form the request
	def get_geo_location
		
		Rails.application.config.request_location = nil;
		# get the location info from the request
		if (true if Float(params[:lat]) rescue false) and (true if Float(params[:long]) rescue false)
			Rails.application.config.request_location = {
				:lat => params[:lat],
				:long => params[:long]
			}
		elsif IPLocation.instance[request.remote_ip]
			Rails.application.config.request_location = IPLocation.instance[request.remote_ip]
		# get the location info from request ip
		elsif request.safe_location.present?
			if request.safe_location.latitude != 0 or request.safe_location.longitude != 0
				Rails.application.config.request_location = {
					:lat => request.safe_location.latitude,
					:long => request.safe_location.longitude
				}
				IPLocation.instance.store(request.remote_ip, { 
					:lat => request.safe_location.latitude,
					:long => request.safe_location.longitude
				})
			end
		end

		logger.tagged('LOCATION') { logger.info "#{ get_location }" } 
	end

	# get the location information
	def get_location
		Rails.application.config.request_location
	end

	def exception_logger
		Rails.application.config.exception_logger
	end

	# params should be skipped in conditional query
	def params_to_skip 
		[:apitoken, :lat, :long, :page, :per_page, :within, :format, :user_role]
	end

	# filter the result by distance
	def filter_and_sort_by_distance(scope, query_parameters)
		if query_parameters[:within] and get_location
			scope.near([get_location[:lat], get_location[:long]], Float(query_parameters[:within]), :units => :km) rescue scope
		else
			scope
		end
	end

	# build mongoid query
	# 1. id=123,,345,,678  
	# 			===> id in [123, 345, 678]
	# 2. created=<=1023456 
	# 			===> created <= 1023456  
	# 3. filtering by fields' existence 
	# 			===> filed=!=null or filed=null
	# 4. to query item within a distance to a certain point 
	# 			===>  within=5 (within 5 kms)
	def query_by_conditions(scope, query_parameters)
		tempResult = scope
		sortBy = query_parameters[:sortBy]
		page = query_parameters[:page]
		per_page = query_parameters[:per_page]

		if params[:user_role]
		  tempResult = User.with_role params[:user_role]
	    end

		query_parameters.except!(*([:sortBy] + params_to_skip)).each do |key, value|
			field = key.to_sym

			logger.tagged('QUERY') { logger.info "key: #{key} , value: #{value}"}
			
			query = {}

			if value.nil?
				logger.tagged('QUERY') { logger.info "query value is empty!"}
			elsif value.start_with? '<='
				query.store(field.lte, value[2..-1])
				# tempResult = tempResult.lte(field.lte => value[2..-1])
			elsif value.start_with? '<'
				query.store(field.lt, value[1..-1])
				# tempResult = tempResult.lt(field => value[1..-1])
			elsif value.start_with? '>='
				query.store(field.gte, value[2..-1])
				# tempResult = tempResult.gte(field => value[2..-1])
			elsif value.start_with? '>'
				query.store(field.gt, value[1..-1])
				# tempResult = tempResult.gt(field => value[1..-1])
			elsif value.start_with? '!='
				if value == "!=null"
					query.store(field.exists, false)
					# tempResult = tempResult.where(field.exists => false)
				else
					query.store(field.nin, value[2..-1].split(',,'))
					# tempResult = tempResult.nin(field => value[2..-1].split(',,'))
				end
			else
				if value == "null"
					query.store(field.exists, true)
					# tempResult = tempResult.where(field.exists => true)
				else
					query.store(field.in, value.split(',,'))
					# tempResult = tempResult.in(field => value.split(',,'))
				end
			end

			tempResult = tempResult.and(query);
		end

		# if 'sortBy' is contained in the query parameters
		if sortBy.present? 
			# multiple sortBy parameters must be seperated by ',,'
			# for instance: 'sortBy=time,,name' ==> means sortBy 'time' and 'name'
			order_by_params = sortBy.split(',,').map do |item|		
				logger.tagged('SORTBY') { logger.info item }	
				if item.start_with? '-'
					[item[1..-1].to_sym, -1]
				else
					[item.to_sym, 1]
				end
			end
			tempResult = tempResult.order_by(order_by_params)
		end

		# if pagenation is required, then return required page
		if page.present? and per_page.present?
			logger.tagged('PAGE') { logger.info "page: #{page} , number per page: #{per_page}" }
			return tempResult.page(page).per(per_page)
		else
			return tempResult.all
		end
	end

	# raise an unauthorized error if no session created or session expired
	# this function is called wherever is restricted for accessing
	def restrict_access
		raise UnauthenticatedError.new unless not @session.nil? and not @session.expire?
	end

	# for every request, try to find the logged in user from the access token
	# , and also refresh the session
	def load_loggedin_user
		@session = Session.find_by(access_token: loads_apikey)
		@session.refresh if not @session.nil? and not @session.expire?
		if not @session.nil? and not @session.expire?
			logger.tagged('LOGGED IN USER') { logger.info "Name: #{@session.user.name} , Email: #{@session.user.email}" }
			@current_user = @session.user
		else
			logger.tagged('LOGGED IN USER') { logger.info "None" }
			@current_user = nil
		end
	end

	# get the apitoken from the request
	def loads_apikey
		@apitoken = params[:apitoken]
	end

	# render errors
	def render_error(error)
		logger.tagged('ERROR', error.status) { logger.info "#{ error.error }" }
		render :json => error, :status => error.status
	end

	# get current user
	# create a guest if no user is found
	def current_user
		@current_user ||= User.new({ :guest => true })
	end

	# if permission denied, send a unauthorized error with code 403
	def permission_denied(error)
		render_error(NotauthorizedError.new)
	end

	# handle general error
	def handle_general_error(error)
		log_id = Time.now.to_s
		logger.tagged('ERROR', 'INTERNAL') { 
			logger.info "Type: #{ error.class.to_s }" 
			logger.info "Message: #{ error.to_s }" 
			logger.info "Details: Please see '[#{ error.class.to_s }] [#{ log_id }]' in *-rails-exceptions.log"
		}
		# log the backtrace into a seperate log file
		exception_logger.tagged(error.class.to_s, log_id) { 
			exception_logger.info '--------------------------------'
			exception_logger.info "       #{ error.class.to_s  }   "
			exception_logger.info '--------------------------------'
			error.backtrace.each do |line|
				exception_logger.info line
			end
			exception_logger.info ''
		}
		# email error message to the developers
		Thread.start {
			ExceptionNotifier.notify_exception(error, :env => request.env)
		}
		render_error(InternalError.new(error.message));
	end

	# bind role 'moderator' to target
	def moderatorize(user, target)
		user.add_role :moderator, target
	end

	def set_default_response_format
		if params[:format].present? and params[:format] == 'html'
			request.format = :html
		else
			request.format = :json
		end
	end

end
