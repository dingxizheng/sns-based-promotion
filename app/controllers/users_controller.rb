class UsersController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory, :add_keyword, :delete_keyword, :update_password]
  before_action :set_user, only: [:rate, :show, :update, :destroy, :add_keyword, :delete_keyword, :reset_password, :reset_password_by_admin_token, :reset_role_by_admin_token, :update_password]


  # GET /users
  # GET /users.json
  def index
    if params[:suggested]
      suggested_index
    elsif params[:suggested_paid]
      suggested_paid
    else
      normal_index
    end
  end

  def normal_index
    result_by_distance = User.with_in_radius(get_location, params[:within])
    if params[:user_role]
      result_by_role = result_by_distance.with_role(params[:user_role])
      if result_by_role.count < 1
        raise EmptyList.new
      end
    end
    queried_result = (result_by_role || result_by_distance).query_by_params(request.query_parameters.except!(*(params_to_skip)))
    @users = queried_result.sortby(params[:sortBy]).paginate(params[:page], params[:per_page])
    render 'users/users', :locals => { :users => @users }
  end

  def suggested_paid
    result_by_distance = User.with_in_radius(get_location, params[:within])
    if params[:user_role]
      result_by_role = result_by_distance.with_role(params[:user_role])
      if result_by_role.count < 1
        raise EmptyList.new
      end
    end
    paid_result = (result_by_role || result_by_distance).query_by_params({ :subscripted => 'true' })
    queried_result = paid_result.query_by_params(request.query_parameters.except!(*(params_to_skip)))
    
    if queried_result.count >= 10
      randomized_results = []
      while randomized_results.count < 10 do
        i = rand(queried_result.count)
        randomized_results << i unless randomized_results.include?(i)
      end 
      @users = randomized_results.map{|i| queried_result[i]}
    else
      @users = queried_result
    end
      
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
    set_images(@user)
    authorize @user
    raise UnprocessableEntityError.new(@user.errors) unless @user.save
    render partial: "users/user", :locals => { :user => @user }, status: :created
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize @user
    set_images(@user)
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
      render :text => 'token expired! role has been reset already.';
    end
  end

  # POST /promotions/1/rate
  def rate
    if current_user.guest
      rater = Anonymity.where(ip: request.remote_ip).first_or_create!
    else
      rater = current_user
    end
    # raise an error if it has been rated before by the same user
    raise DuplicateError.new('you already rated this one.')  unless not @user.rated_by? rater
    @user.rate Float(params[:rating]), rater
    raise UnprocessableEntityError.new(@user.errors) unless @user.save
    render :partial => 'users/user', :locals => { :user => @user }
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize @user
    @user.destroy
    head :no_content
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

  # get image ids from the request params and bind them to the user object
  def set_images(user)
    logo = Image.find(params[:user][:logo_id] || 'false')
    background = Image.find(params[:user][:background_id] || 'false')

    flag = false
    if logo.present?
      user.logo = logo
      flag = true
    end

    if background.present?
      user.background = background
      flag = true
    end
    return flag
  end

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

end
