module V1
  class UsersController < ApplicationController

    include VoteableActions
    voteable :user

    before_action :restrict_access, only: [:create, :update, :destory, :vote_up, :vote_down]
    before_action :set_user, except: [:create]


    # GET /users
    # GET /users.json
    def index
      result_by_distance = User.with_in_radius(get_location, params[:within])
      if params[:user_role]
        result_by_role = result_by_distance.with_role(params[:user_role])
        if result_by_role.count < 1
          raise EmptyList.new
        end
      end
      queried_result = (result_by_role || result_by_distance).query_by_params(request.query_parameters.except!(*(params_to_skip)))
      @users = queried_result.sortby(params[:sortBy]).paginate(params[:page], params[:per_page])
      render_json "users/user", :locals => { :user => @user }
    end

    # GET /users/1
    # GET /users/1.json
    def show
      render_json "users/user", :locals => { :user => @user }
    end

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)
      authorize @user
      raise UnprocessableEntityError.new(@user.errors) unless @user.save
      render_json "users/user", :locals => { :user => @user }, status: :created
    end

    # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
      authorize @user
      raise UnprocessableEntityError.new(@user.errors) unless @user.update(user_params)
      render_json "users/user", :locals => { :user => @user }
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      authorize @user
      @user.destroy
      head :no_content
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      user_id = params[:id] || params[:user_id]
      @user = User.find(user_id)
      # raise a notfound error, if @user is empty
      raise NotfoundError.new('User', { :id => user_id }.to_s ) unless @user
    end

    def user_params
      params.permit(:name, :phone, :email, :address, :description, :password)
    end

  end
end
