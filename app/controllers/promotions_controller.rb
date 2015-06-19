class PromotionsController < ApplicationController

  # always put this at top
  before_action :restrict_access, only: [:create, :update, :destory, :approve, :reject]
  before_action :set_promotion, except: [:index]
  before_action :set_owner, except:[]
  
  # GET /promotions
  # GET /promotions.json
  def index
    promotions_before_query = PromotionPolicy::Scope.new(@owner, Promotion).resolve
    @promotions = query_by_conditions(promotions_before_query, request.query_parameters)
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
    identity = request.remote_ip
    type = 'ip'
    identity = current_user.get_id unless current_user.guest
    type = 'id' unless current_user.guest
    @promotion.rate Float(params[:rating]), identity, type
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
