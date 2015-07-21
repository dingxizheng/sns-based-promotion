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

		@user.session.destroy unless not @user.session.presence

		# otherwise create a new seession
		session = Session.new
		session.save
		session.refresh
		@user.session = session

		render :partial => 'users/session', :locals => { :session => session }

	end

	# POST /signout
	def signout
		@session.destroy
		head :no_content
	end

	# POST /signup
	def signup_with_email
		@user = User.new(signup_params)
		raise UnprocessableEntityError.new(@user.errors) unless @user.save
    	render partial: "users/user", :locals => { :user => @user }, status: :created
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
