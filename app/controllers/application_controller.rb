require 'digest'
class ApplicationController < ActionController::Base

	include ActionController::HttpAuthentication::Token::ControllerMethods
	include Errors
	include Pundit
	include PublicActivity::StoreController

	before_action :get_geo_location, :find_session

	# set default response format to json
	before_filter :set_default_response_format

	# return empty list
	rescue_from EmptyList, :with => :render_empty_list

	# capture all standard http errors
	rescue_from MyError, :with => :handle_http_error

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

	helper_method :get_location, :current_user

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

	# params should be skipped in conditional query
	def params_to_skip 
		[:access_token, :lat, :long, 
			:page, :per_page, :distance, 
			:format, :user_role, :sortBy, :search
		]
	end

	# return valid query parameters
	def query_params
		request.query_parameters.except!(*params_to_skip)
	end

	def search
		params[:search]
	end

	def sortBy
		request.headers['HTTP_SORTBY']
	end

	def page
		request.headers['HTTP_PAGE'] || 1 #=> return the first page by default
	end

	def per_page
		request.headers['HTTP_PER_PAGE'] || 8 #=> default items per_page is set to 8
	end

	def distance
		params[:distance]
	end

	def user_role
		params[:user_role] || 'user'
	end

	# raise an unauthorized error if no session created or session expired
	# this function is called wherever is restricted for accessing
	def restrict_access
		raise UnauthenticatedError.new unless not @session.nil? and not @session.expire?
	end

	# for every request, try to find the logged in user from the access token
	# , and also refresh the session
	def find_session
		hashed_token = Digest::SHA2.hexdigest(params[:access_token] || "")
      	@session = Session.find_by(access_token_hashed: hashed_token)
		@session.refresh unless @session.nil? or @session.expire?
		unless @session.nil? or @session.expire?
			logger.tagged('SESSION FOUND') { logger.info "Name: #{@session.user.name} , Email: #{@session.user.email}" }
			@current_user = @session.user
		end
	end

	# return empty list
	def render_empty_list
		render :json => []
	end

	def render_error(error)
		render :json => error, :status => error.status
	end

	# render standard http errors
	def handle_http_error(error)
		logger.tagged('ERROR', error.status) { logger.info "#{ error.error }" }
		render_error(error)
	end

	# get current user
	# create a guest if no user is found
	def current_user
		@current_user
	end

	# if permission denied, send a unauthorized error with code 403
	def permission_denied(error)
		render_error(NotauthorizedError.new)
	end

	# handle general error
	def handle_general_error(error)
		Utility.log_exception(error, {})
		render_error(InternalError.new(error.message))
	end

	# bind role 'moderator' to target
	def moderatorize(user, target)
		user.add_role :moderator, target
	end

	# set default response format
	def set_default_response_format
		if params[:format].present? and params[:format] == 'html'
			request.format = :html
		else
			request.format = :json
		end
	end

	# render json reponse by using jbuilder
	def render_json(*args)
		view_path, params = *args
		namespace = controller_path.split('/').first
		if namespace.size > 1
			render "#{namespace}/#{view_path}", params
		else
			render "#{view_path}", params
		end
	end

end
