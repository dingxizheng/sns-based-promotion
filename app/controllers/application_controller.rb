class ApplicationController < ActionController::API

	include ActionController::HttpAuthentication::Token::ControllerMethods
	include Errors
	include Pundit


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

end
