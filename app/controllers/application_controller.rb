class ApplicationController < ActionController::API

	include ActionController::HttpAuthentication::Token::ControllerMethods

	# private methods
	protected
	  def restrict_access
	  	@session = Session.find_by(access_token: loads_apikey)
	  	if @session.nil?
	  		render :json => { error: 'Unauthorized!' }, :status => 401
	  	else
	  		if @session.expire?
	  			render :json => { error: 'Your session expired!' }, :status => 401
	  		else
	  			@current_user = @session.user
	  		end
	  	end
	  end

	  def loads_apikey
	  	@apitoken = params[:apitoken]
	  end

end
