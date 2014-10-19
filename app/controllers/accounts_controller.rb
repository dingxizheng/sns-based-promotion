class AccountsController < ApplicationController

	before_action :restrict_access, only: [:signout]
	before_action :signup_params, only: [:signup_with_email]


	# POST /signin
	def signin
		@user = User.find_by(email: params[:email])
		
		if not @user.nil?
			if @user.password_match?(params[:password])		
				session = Session.new
				session.save
				@user.session = session
				render :json => { :token => session.access_token }
			else
				render :json => { :error => 'password is not correct.' }, :status => 400
			end
		else
			render :json => { :error => 'user does not exist in our system.' }, :status => 400
		end

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

	# POST /signin/facebook
	def sign_with_facebook
	end

	# private methods
	private
	  def signup_params
      params.require(:user).permit(:name, :email, :password)
    end

end
