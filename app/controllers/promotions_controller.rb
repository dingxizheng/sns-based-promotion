class PromotionsController < ApplicationController

  # always put this at top
  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_promotion, only: [:show, :update, :destroy]
  before_action :set_owner, except:[]
  
  # GET /promotions
  # GET /promotions.json
  def index
    @promotions = PromotionPolicy::Scope.new(@owner, Promotion).resolve
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

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    authorize @promotion
    @promotion.destroy
    head :no_content
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promotion
      @promotion = Promotion.find(params[:id])
      raise NotfoundError.new('Promotion', { :id => params[:id] }.to_s ) unless @promotion
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_params
      params.require(:promotion).permit(:title, :body, :start_at, :expire_at)
    end

    # load owner
    def set_owner
      if params[:user_id]
        @owner = User.find(params[:user_id])
        raise NotfoundError.new('User', { :id => params[:user_id] }.to_s ) unless @owner
      else
        @owner = current_user
      end
      puts @owner.to_yaml
    end

end
