class ReviewsController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :set_user, except: []

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = PromotionPolicy::Scope.new(@user, Review).resolve
    # @reviews = query_by_conditions(@reviews, request.query_parameters.except!(params_to_skip))
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
    @review = @reviewer.opinions.build(review_params)
    authorize @review
    moderatorize review.reviewer, @review
    raise UnprocessableEntityError.new(@review.errors) unless @review.save
    render :partial => 'reviews/review', :locals => { :review => @review }, status: :created

  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    authorize @review
    raise UnprocessableEntityError.new(@review.errors) unless @review.update(params[:review])     
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
      @review = Review.find(params[:id])
      raise NotfoundError.new('Review', { :id => params[:id] }.to_s ) unless @review
    end

    # only permit the trusted paramsters
    def review_params
      params.require(:review).permit(:body, :customer_id)
    end

    # load customer resources
    def set_user
      if params[:user_id]
        @user = User.find(params[:user_id])
        raise NotfoundError.new('User', { :id => params[:user_id] }.to_s ) unless @review
      else
        @user = current_user
      end
    end

end
