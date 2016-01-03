class PromotionsController < ApplicationController

  # always put this at top
  before_action :restrict_access, only: [:create, :update, :destory, :approve, :reject, :add_keyword, :delete_keyword, :rate]
  before_action :set_promotion, except: [:index, :create]
  before_action :set_owner, except:[]

  # GET /promotions
  # GET /promotions.json
  def index
    if params[:suggested_paid]
      suggested_paid
    else
      normal_index
    end
  end

  # this method handles normal requests
  def normal_index
    romotions_before_query = PromotionPolicy::Scope.new(@owner, Promotion, params).resolve
    if params[:catagory_id]
      promotions_by_category = romotions_before_query.by_category(params[:catagory_id])
      if promotions_by_category.count < 1
        raise EmptyList.new
      end
    end
    result_by_distance = (promotions_by_category || romotions_before_query).with_in_radius(get_location, params[:within])
    queried_result = result_by_distance.query_by_params(request.query_parameters.except!(*(params_to_skip)))
    @promotions = queried_result.sortby(params[:sortBy]).paginate(params[:page], params[:per_page])
    render 'promotions/promotions', :locals => { :promotions => @promotions }
  end

  # this method is being used to return suggested results when search result is returned 
  def suggested_paid
    romotions_before_query = PromotionPolicy::Scope.new(@owner, Promotion, params).resolve
    # filter results by category id
    if params[:catagory_id] and params[:catagory_id].to_s != 'all'
      promotions_by_category = romotions_before_query.where({ :catagory_id => params[:catagory_id]})
    end
    # filter results by distance
    result_by_distance = (promotions_by_category || romotions_before_query).with_in_radius(get_location, params[:within])
    # filter resutls by payment status
    paid_results = result_by_distance.query_by_params({ :subscripted => 'true' })
    queried_result = paid_results.query_by_params(request.query_parameters.except!(*(params_to_skip)))
    num_to_get = (params[:num] || '10').to_i
    count = queried_result.count
    @promotions = queried_result.randomized(num_to_get)
    while count > num_to_get and @promotions.count < num_to_get
       @promotions = queried_result.randomized(num_to_get)
    end
    
    render 'promotions/promotions', :locals => { :promotions => @promotions }
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    respond_to do |format|
      format.html { render 'shares/promotion.html.erb' }
      format.json { render :partial => 'promotions/promotion', :locals => { :promotion => @promotion } }
    end

  end

  # POST /promotions
  # POST /promotions.json
  def create
    if @owner.promotions.in(:status => ['reviewed', 'submitted']).count >= 1
      raise BadRequestError.new('you only can have 1 active promotions')
    end
    @promotion = @owner.promotions.build(promotion_params)
    authorize @promotion
    moderatorize @owner, @promotion

    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
    set_images(@promotion)
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }, status: :created
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update
    authorize @promotion
    set_images(@promotion)
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.update(promotion_params)
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # POST /promotions/1/rate
  def rate
    if current_user.guest
      rater = Anonymity.where(ip: request.remote_ip).first_or_create!
    else
      rater = current_user
    end

    # raise an error if it has been rated before by the same user
    raise DuplicateError.new('you already rated this one.')  unless not @promotion.rated_by? rater

    @promotion.rate Float(params[:rating]), rater

    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    authorize @promotion
    @promotion.destroy
    head :no_content
  end

  # POST /promotions/1/approve
  def approve
    authorize @promotion
    @promotion.approve
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
    @promotion.create_approval_msg(current_user)
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # POST /promotions/1/reject
  def reject
    authorize @promotion
    @promotion.reject params[:reason]
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
    @promotion.create_rejection_msg(current_user)
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # POST /promotions/1/report
  def report
    PromotionMailer.reported_to_admin(@promotion, params[:reason]).deliver_now!
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # POST /promotions/1/notify
  def notify
    PromotionMailer.notification_request(@promotion).deliver_now!
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # GET /promotions/1/approvebyadmintoken
  def approve_by_admin_token
    if Token.find(params[:admin_token]).present?
      @promotion.approve
      raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
      @promotion.create_approval_msg
      Token.find(params[:admin_token]).destroy
      render :text => 'request has been approved successfully!';
    else
      render :text => 'token expired! the request has been approved already!';
    end
  end

  # GET /promotions/1/cancelbyadmintoken
  def cancel_by_admin_token
    if Token.find(params[:admin_token]).present?
      @promotion.reject 'no reason'
      Token.find(params[:admin_token]).destroy
      raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
      @promotion.create_rejection_msg
      render :text => 'request has been cancelled successfully!';
    else
      render :text => 'token expired! the request has been cancelled already!';
    end
  end

  # GET /promotions/1/notifybyadmintoken
  #
  # once the link in the email got clicked,
  # this function will be executed.
  def notify_by_admin_token

    # firstly, it checks if the current token passed with the request is valid or not
    if Token.find(params[:admin_token]).present?
      # since sending notifications is a time consuming task,
      # it will be wraped and executed in a seperate thread
      Thread.start {
        #####################################
        # ios notifications
        #####################################
        Device.where({:os => 'ios'}).each { |device|
          puts device.token
          notification = Houston::Notification.new(device: device.token)
          notification.alert = @promotion.customer.name + ": " + @promotion.title + "\n" + @promotion.description
          notification.sound = "sosumi.aiff"
          notification.content_available = true
          notification.custom_data = {
            promotion_id: @promotion.get_id,
            user_id: @promotion.customer.get_id
          }
          # push the notification
          APNS.get.push(notification)
        }

        ####################################
        # android notifications
        ####################################

        # gather all the android devices, and put them into a array
        devices = Device.where({ :os => 'android' }).map { |device|
          device.token
        }

        # send notifications to all android devices
        response = GCM.get.send(devices, {
                                  # the date will be pushed to remote
                                  data: {
                                    title: 'New Deal',
                                    message: @promotion.customer.name + ": " + @promotion.title + "\n" + @promotion.description,
                                    promotion_id: @promotion.get_id,
                                    user_id: @promotion.customer.get_id
                                  }
        })

        puts response
      }

      render :text => 'notification job has been submitted';
    else
      render :text => 'token expired! the request has been cancelled already!';
    end
  end

  # keywords functions
  # POST /promotions/1/keywords
  def add_keyword
    authorize @promotion
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.add_keyword(params[:keyword])
    Sunspot.index! [@promotion]
    head :no_content
  end

  # DELETE /promotion/1/keywords/:keyword
  def delete_keyword
    authorize @promotion
    @promotion.pull(keywords: params[:keyword])
    Sunspot.index! [@promotion]
    head :no_content
  end

  private

  # Set images
  def set_images(promotion)
    cover = Image.find(params[:promotion][:cover_id] || 'false')
    flag = false
    if cover.present?
      cover.promotion = promotion
      cover.save
      flag = true
    end
    return flag
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_promotion
    @promotion = Promotion.find(params[:id] || params[:promotion_id])
    raise NotfoundError.new('Promotion', { :id => params[:id] || params[:promotion_id] }.to_s ) unless @promotion
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def promotion_params
    params.require(:promotion).permit(:title, :description, {keywords: []}, :catagory_id, :start_at, :expire_at)
  end

  # load owner
  def set_owner
    if params[:user_id]
      @owner = User.find(params[:user_id])
      raise NotfoundError.new('User', { :id => params[:user_id] }.to_s ) unless @owner
    else
      # if user_id is not provided, set it as nil by default
      @owner = @current_user || User.new({ :guest => true })
    end
  end

end
