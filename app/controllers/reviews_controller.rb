class ReviewsController < ApplicationController

  before_action :restrict_access, only: [:update, :destory, :create]
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :set_user, except: []

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = ReviewPolicy::Scope.new(@reviewer, Review).resolve
                  .query_by_params(request.query_parameters.except!(*(params_to_skip)))
                  .sortby(params[:sortBy])
                  .paginate(params[:page], params[:per_page])
    render 'reviews/reviews', :locals => { :reviews => @reviews }
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    render :partial => 'reviews/review', :locals => { :review => @review }
  end

  # POST /reviews
  # POST /reviews.json
  def create

    if not @reviewer.guest
      raise DuplicateError.new('you already commented on this one.') unless not Review.commented_by?(@reviewer, review_params.extract!(:customer_id, :promotion_id))
      @review = @reviewer.opinions.build(review_params)
      authorize @review
      moderatorize @review.reviewer, @review
    else
      anonymity = Anonymity.where(ip: request.remote_ip).first_or_create!
      raise DuplicateError.new('you already commented on this one.') unless not Review.commented_by?(anonymity, review_params.extract!(:customer_id, :promotion_id))
      @review = Review.new(review_params)
      @review.anonymity_id = anonymity.id
    end

    raise UnprocessableEntityError.new(@review.errors) unless @review.save
    render :partial => 'reviews/review', :locals => { :review => @review }, status: :created
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    authorize @review
    raise UnprocessableEntityError.new(@review.errors) unless @review.update(review_params)     
    render :partial => 'reviews/review', :locals => { :review => @review }
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    authorize @review
    @review.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id] || params[:review_id])
      raise NotfoundError.new('Review', { :id => params[:id] || params[:review_id] }.to_s ) unless @review
    end

    # only permit the trusted paramsters
    def review_params
      if params[:review][:customer_id]   
        params.require(:review).permit(:body, :customer_id)
      else
        params.require(:review).permit(:body, :promotion_id)
      end
    end

    # load customer resources
    def set_user
      if params[:user_id]
        @reviewer = User.find(params[:user_id])
        raise NotfoundError.new('User', { :id => params[:user_id] }.to_s ) unless @review
      else
        @reviewer = current_user
      end
    end

end
