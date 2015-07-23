class PromotionsController < ApplicationController

  # always put this at top
  before_action :restrict_access, only: [:create, :update, :destory, :approve, :reject]
  before_action :set_promotion, except: [:index, :create]
  before_action :set_owner, except:[]
  
  # GET /promotions
  # GET /promotions.json
  def index
    # fitler the results by distance provided
    result_by_distance = filter_and_sort_by_distance(Promotion, request.query_parameters)
    # filter the results by users' role
    promotions_before_query = PromotionPolicy::Scope.new(@owner, result_by_distance).resolve
    # filter the reuslts by query parameters
    @promotions = query_by_conditions(promotions_before_query, request.query_parameters)
    # render the results
    render 'promotions/promotions', :locals => { :promotions => @promotions }
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # POST /promotions
  # POST /promotions.json
  def create
    @promotion = @owner.promotions.build(promotion_params)
    authorize @promotion
    moderatorize @owner, @promotion
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }, status: :created
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update
    authorize @promotion
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
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # POST /promotions/1/reject
  def reject
    authorize @promotion
    @promotion.reject params[:reason]
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save
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
      render :text => 'request has been cancelled successfully!';
    else
      render :text => 'token expired! the request has been cancelled already!';
    end
  end

  # GET /promotions/1/notifybyadmintoken
  def notify_by_admin_token
    if Token.find(params[:admin_token]).present?

      # since sending notifications is a time consuming task, 
      # it will be wraped and executed in a seperate thread 
      Thread.start {
        #####################################
        # ios notifications
        #####################################
        Device.where({:os => 'ios'}).each { |device|
          notification = Houston::Notification.new(device: device.token)
          notification.alert = @promotion.customer.name + ": " + @promotion.title + "\n" + @promotion.description
          notification.sound = "sosumi.aiff"
          notification.content_available = true
          notification.custom_data = { 
            promotion_id: @promotion.get_id, 
            user_id: @promotion.customer.get_id
          }
          APNS.get.push(notification)
        }

        ####################################
        # android notifications
        ####################################
        #
        # gather all the android devices
        devices = Device.where({ :os => 'android' }).map { |device|
          device.token
        }

        # send notifications to all dndroid devices
        response = GCM.get.send(devices, {
          # the date will be pushed to remote 
          data: { 
            title: 'new promotion',
            message: @promotion.customer.name + ": " + @promotion.title + "\n" + @promotion.description,
            promotion_id: @promotion.get_id, 
            user_id: @promotion.customer.get_id
          },
          collapse_key: 'vicinity_deals'
        })

        puts response
      }

      render :text => 'notification job has been submitted';
    else
      render :text => 'token expired! the request has been cancelled already!';
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_promotion
      @promotion = Promotion.find(params[:id] || params[:promotion_id])
      raise NotfoundError.new('Promotion', { :id => params[:id] || params[:promotion_id] }.to_s ) unless @promotion
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_params
      params.require(:promotion).permit(:title, :description, :catagory_id, :start_at, :expire_at)
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
