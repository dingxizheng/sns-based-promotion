class V1::AccountsController < ApplicationController

  before_action :restrict_access, only: [:signout, :me]

  # POST /signin
  def signin
    @user = User.find_by(email: params[:email].downcase)
    # if user is not found, raise a 400 error
    raise BadRequestError.new('user does not exist') unless not @user.nil?
    # if password does not match, raise a 400 error
    raise BadRequestError.new('wrong password') unless @user.password_match?(params[:password])

    # @user.session.destroy unless not @user.session.presence

    # delete expired sessions
    @user.sessions.each{|s| s.destroy unless not s.expire?}

    # otherwise create a new seession
    session = Session.new
    session.save
    session.refresh
    @user.sessions << session

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
    # get current user's information
    render :partial => 'users/session', :locals => { :session => @session }
  end

  # POST /signin/facebook
  def signin_with_facebook
    # validate facebook access token
    # raise BadRequestError.new(I18n.t('errors.requests.invalid_access_token')) unless Utility.is_facebook_token_valid? signin_with_fb_params[:provider_access_token]
    
    @user = User.find_by(id_from_provider: signin_with_fb_params[:id])
    # create a new user if user does not exists  
    if @user.nil?
      @user = User.new({
          :email => signin_with_fb_params[:email],
          :name => signin_with_fb_params[:name],
          :id_from_provider => signin_with_fb_params[:id],
          :provider => 'facebook',
          :profile_picture => (Settings.facebook.graph_api.profile_picture % signin_with_fb_params[:id])
        })
      raise UnprocessableEntityError.new(@user.errors) unless @user.save
    end

    # delete all expired sessions
    @user.sessions.each{|s| s.destroy unless not s.expire?}

    # create a new session
    @session = @user.sessions.build({
       :provider => 'facebook',
       :provider_access_token => signin_with_fb_params[:provider_access_token],
       :expire_at => signin_with_fb_params[:expire_at],
      })

    # return session object
    render :partial => 'users/session', :locals => { :session => @session  }
  end

  # private methods
  private
  def signup_params
    params.permit(:name, :email, :password)
  end

  def signin_with_fb_params
    params.permit(:id, :name, :email, :provider_access_token, :provider, :expire_at, :profile_picture)
  end
end