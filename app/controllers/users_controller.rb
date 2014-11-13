class UsersController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :load_customer, only: [:add_keyword, :delete_keyword, :set_logo]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    Image.all.each do |i|
      puts i.user
    end
    render 'users/users', :locals => { :users => @users }
  end

  # GET /users/1
  # GET /users/1.json
  def show
    render partial: "users/user", :locals => { :user => @user } 
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    raise UnprocessableEntityError.new(@user.errors) unless @user.save
    render partial: "users/user", :locals => { :user => @user }, status: :created
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    raise UnprocessableEntityError.new(@user.errors) unless @user.update(user_params)
    render partial: "users/user", :locals => { :user => @user }
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    head :no_content
  end

  # POST /users/1/logo
  def set_logo
    raise UnprocessableEntityError.new(@customer.errors) unless @customer.set_logo(params[:logo])
    render partial: "users/user", :locals => { :user => @user }
  end

  # keywords functions
  # POST /users/1/keywords
  def add_keyword
    raise UnprocessableEntityError.new(@customer.errors) unless @customer.add_keyword(params[:keyword])
    render :json => { :keyword => params[:keyword] }
  end

  # DELETE /users/1/keywords/:keyword
  def delete_keyword
    @customer.pull(keywords: params[:keyword])
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
      # raise a notfound error, if @user is empty
      raise NotfoundError.new('User', { :id => params[:id] }.to_s) unless @user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      # puts params.require(:user)
      params.require(:user).permit(:name, :phone, :email, :address, :description)
    end

    def user_logo
      params.require(:user).permit(:logo)
    end

    # load customer resources
    def load_customer
      if params[:user_id]
        @customer = User.find(params[:user_id])
      else
        @customer = @current_user
      end
    end

end
