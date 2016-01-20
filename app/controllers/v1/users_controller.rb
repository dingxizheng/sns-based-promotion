class V1::UsersController < ApplicationController

  include VoteableActions
  voteable :user

  include TaggableActions
  taggable :user

  include FollowableActions
  followable :user

  before_action :restrict_access, except: [:index, :show]
  before_action :set_user, except: [:create, :index]

  # GET /users
  # GET /users.json
  def index
    @users = User.with_in_radius(get_location, distance)
    @users = @users.with_role(user_role)
    if @users.count > 1
      @users = @users.query_by_params(query_params)
                     .query_by_text(search)
                     .sortby(sortBy)
                     .paginate(page, per_page)
    end

    render_json "users/users", :locals => { :users => @users }
  end

  # GET /users/1
  # GET /users/1.json
  def show
    render_json "users/user_full", :locals => { :user => @user }
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    authorize @user
    @user.set_avatar params[:avatar] if params[:avatar]
    @user.set_background params[:background] if params[:background]
    raise UnprocessableEntityError.new(@user.errors) unless @user.save
    render_json "users/user_full", :locals => { :user => @user }, status: :created
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize @user
    @user.set_avatar params[:avatar] if params[:avatar]
    @user.set_background params[:background] if params[:background]
    raise UnprocessableEntityError.new(@user.errors) unless @user.update(user_params)
    render_json "users/user_full", :locals => { :user => @user }
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  private
  def set_user
    @user = User.find(params[:id] || params[:user_id])
    raise NotfoundError.new(I18n.t('errors.requests.default_not_found') % request.path) if @user.nil?
  end

  def user_params
    params.permit(:name, :phone, :email, :address, :description, :password, :tags => [])
  end

end