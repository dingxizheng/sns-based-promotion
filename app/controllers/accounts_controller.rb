class AccountsController < ApplicationController

	before_action :restrict_access, only: [:signout, :me]
	before_action :signup_params, only: [:signup_with_email]


	# POST /signin
	def signin
		@user = User.find_by(email: params[:email])
		
		# if user is not found, raise a 400 error
		raise BadRequestError.new('user does not exist.') unless not @user.nil?
		
		# if password does not match, raise a 400 error
		raise BadRequestError.new('invalid password.') unless @user.password_match?(params[:password])

		# otherwise create a new seession
		session = Session.new
		session.save
		@user.session = session
		# response with apitoken
		# render :json => { :apitoken => session.access_token }

		render :partial => 'users/session', :locals => { :session => session }

	end

	# POST /signout
	def signout
		@session.destroy
	end

	# POST /signup
	def signup_with_email
		@user = User.new(signup_params)
		if @user.save
			render json: @user, status: :created, location: @user
		else
			render json: @user.errors, status: :unprocessable_entity
		end
	end

  # GET /me
	def me
		render :partial => 'users/session', :locals => { :session => @session }
	end

	# POST /signin/facebook
	def sign_with_facebook
	end

	# private methods
	private
	  def signup_params
      params.require(:user).permit(:name, :email, :password)
    end

end
