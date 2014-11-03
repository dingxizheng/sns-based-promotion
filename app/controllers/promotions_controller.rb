class PromotionsController < ApplicationController

  # always put this at top
  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_promotion, only: [:show, :update, :destroy]
  before_action :load_customer, only: [:index, :create]

  # GET /promotions
  # GET /promotions.json
  def index
    if @customer.nil?
      @promotions = Promotion.all
    else 
      @promotions = @customer.promotions
    end
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
    # create a promotion without customer if customer is nil
    if @customer.nil?
      @promotion = Promotion.new(promotion_params)
    else
      @promotion = @customer.promotions.build(promotion_params)
    end

    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save

    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }, status: :created
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.update(promotion_params)
    render :partial => 'promotions/promotion', :locals => { :promotion => @promotion }
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    @promotion.destroy
    head :no_content
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promotion
      @promotion = Promotion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_params
      params.require(:promotion).permit(:title, :body, :start_at, :expire_at)
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
