class ApplicationController < ActionController::Base

	include ActionController::HttpAuthentication::Token::ControllerMethods
	include Errors
	include Pundit

	
	before_action :get_geo_location, :load_loggedin_user

	# set default response format to json
	before_filter :set_default_response_format

	# return empty list
	rescue_from EmptyList, :with => :render_empty_list

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
			{ :host => ENV["APP_HOST"] }
		else
			{}
		end
	end

	# get geo information form the request
	def get_geo_location
		
		# puts "From...: #{ request.user_agent }"

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
		if (false if Rails.application.config.request_location[:lat] rescue true)
			nil
		else
			Rails.application.config.request_location
		end
	end

	def exception_logger
		Rails.application.config.exception_logger
	end

	# params should be skipped in conditional query
	def params_to_skip 
		[:apitoken, :lat, :long, :page, :per_page, :within, :format, :user_role, :sortBy, :suggested, :suggested_paid]
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

	# return empty list
	def render_empty_list
		render :json => []
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
