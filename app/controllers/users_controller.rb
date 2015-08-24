class UsersController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory, :set_logo, :add_keyword, :delete_keyword, :update_password]
  before_action :set_user, only: [:show, :update, :destroy, :set_logo, :add_keyword, :delete_keyword, :reset_password, :reset_password_by_admin_token, :reset_role_by_admin_token, :update_password]


  # GET /users
  # GET /users.json
  def index
    result_by_distance = filter_and_sort_by_distance(User, request.query_parameters)
    @users = query_by_conditions(result_by_distance, request.query_parameters)
    render 'users/users', :locals => { :users => @users }
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html { render 'shares/user.html.erb' }
      format.json { render partial: "users/user", :locals => { :user => @user } }
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    authorize @user
    raise UnprocessableEntityError.new(@user.errors) unless @user.save
    render partial: "users/user", :locals => { :user => @user }, status: :created
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize @user
    @user.hours = params[:user][:hours] unless params[:user][:hours].nil?
    raise UnprocessableEntityError.new(@user.errors) unless @user.update(user_params)     
    render partial: "users/user", :locals => { :user => @user }
  end

  # POST /users/1/newpassword
  def update_password
    if @user.password_match?(params[:current_password])
      @user.password = params[:new_password]
      @user.encrypt_password
      raise UnprocessableEntityError.new(@user.errors) unless @user.save
    else 
      raise GampError.new(500, 'the current password is not correct!')
    end
    render partial: "users/user", :locals => { :user => @user }
  end

  # POST /users/1/reset
  def reset_password
    UserMailer.reset_password(@user).deliver_now!
    render partial: "users/user", :locals => { :user => @user }
    # authorize @user
    # password = @user.reset_password
    # raise UnprocessableEntityError.new(@user.errors) unless @user.save
    # render {:password => password}
  end

  # GET /users/1/resetpasswordbytoken
  def reset_password_by_admin_token
    if Token.find(params[:admin_token]).present?
      password = @user.reset_password
      UserMailer.new_password(@user, password).deliver_now!
      @user.encrypt_password
      raise UnprocessableEntityError.new(@user.errors) unless @user.save
      Token.find(params[:admin_token]).destroy
      render :text => 'password has been reset successfully!';
    else
      render :text => 'token expired! password has been reset already.';
    end
  end

  # GET /users/1/resetrolebytoken
  def reset_role_by_admin_token
    if Token.find(params[:admin_token]).present?
      @user.description = nil
      @user.remove_role :customer
      raise UnprocessableEntityError.new(@user.errors) unless @user.save
      Token.find(params[:admin_token]).destroy
      render :text => 'user\'s role has been reset successfully!';
    else
      render :text => 'token expired! password has been reset already.';
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  # POST /users/1/logo
  def set_logo
    authorize @user
    raise UnprocessableEntityError.new(@user.errors) unless @user.set_logo(params[:logo])
    render partial: "users/user", :locals => { :user => @user }
  end

  # keywords functions
  # POST /users/1/keywords
  def add_keyword
    authorize @user
    raise UnprocessableEntityError.new(@user.errors) unless @user.add_keyword(params[:keyword])
    Sunspot.index! [@user]
    head :no_content
  end

  # DELETE /users/1/keywords/:keyword
  def delete_keyword
    authorize @user
    @user.pull(keywords: params[:keyword])
    Sunspot.index! [@user]
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    # puts params.require(:user)
    params.require(:user).permit(:name, :phone, :email, :address, :description, :password, :hours)
  end

  def user_logo
    params.require(:user).permit(:logo)
  end

end
