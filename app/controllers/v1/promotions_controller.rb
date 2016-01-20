class V1::PromotionsController < ApplicationController

  # always put this at top
  include VoteableActions
  voteable :promotion

  include TaggableActions
  taggable :promotion

  include FollowableActions
  followable :promotion

  before_action :restrict_access, except: [:index, :show, :reposts, :ancestors]
  before_action :set_promotion, except: [:create, :index]
  before_action :set_owner

  # GET /promotions
  # GET /promotions.json
  def index
    @promotions = PromotionPolicy::Scope.new(current_user, Promotion, { owner: @owner })
                    .resolve
                    .with_in_radius(get_location, distance)
                    .query_by_params(query_params)
                    .query_by_text(search)
                    .sortby(sortBy)
                    .paginate(page, per_page)

    render_json "promotions/promotions", :locals => { :promotions => @promotions }
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    authorize @promotion
    render_json 'promotions/promotion_full', :locals => { :promotion => @promotion }
  end

  # GET /promotions/1/resposts
  def reposts
    @promotions = PromotionPolicy::Scope.new(current_user, @promotion.reposts)
                .resolve
                .with_in_radius(get_location, distance)
                .query_by_params(query_params)
                .query_by_text(search)
                .sortby(sortBy)
                .paginate(page, per_page)

    render_json 'promotions/promotions', :locals => { :promotions => @promotions }
  end

  # GET /promotions/1/ancestors
  def ancestors
    @promotions = PromotionPolicy::Scope.new(current_user, @promotion.ancestors)
                .resolve
                .with_in_radius(get_location, distance)
                .query_by_params(query_params)
                .query_by_text(search)
                .sortby(sortBy)
                .paginate(page, per_page)

    render_json 'promotions/promotions', :locals => { :promotions => @promotions }
  end

  # POST /promotions
  # POST /promotions.json
  def create
    if get_location and get_location[:lat]
      promotion_params_with_geo = promotion_params.merge({:coordinates => [get_location[:long], get_location[:lat]]})
    end
    @promotion = (@owner || current_user).promotions.new(promotion_params_with_geo || promotion_params)
    authorize @promotion
    @promotion.set_photos params[:photos] if params[:photos]
    @promotion.set_photos params[:video] if params[:video]
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.save  
    moderatorize current_user, @promotion
    render_json 'promotions/promotion_full', :locals => { :promotion => @promotion }, status: :created
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update
    authorize @promotion
    raise UnprocessableEntityError.new(@promotion.errors) unless @promotion.update(promotion_update_params)     
    render_json 'promotions/promotion_full', :locals => { :promotion => @promotion }
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    authorize @promotion
    @promotion.destroy
    head :no_content
  end

  private
  def set_promotion
    @promotion = Promotion.find(params[:id] || params[:promotion_id])
    raise NotfoundError.new(I18n.t('errors.requests.default_not_found') % request.path) if @promotion.nil?
  end

  def set_owner
    @owner = User.find(params[:user_id] || "")
  end

  def promotion_update_params
    params.permit(:body, :start_at, :expire_at, :tags => [])
  end

  def promotion_params
    if params[:parent_id]
      params.permit(:body, :parent_id)
    else
      params.permit(:body, :start_at, :expire_at, :tags => [])
    end
  end

end