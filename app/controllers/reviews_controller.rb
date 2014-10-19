class ReviewsController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :load_reviewer

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.all

    render json: @reviews
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    @review = Review.find(params[:id])

    render json: @review
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = @reviewer.opinions.build(review_params)
    if @review.save
      render json: @review, status: :created, location: @review
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    @review = Review.find(params[:id])

    if @review.update(params[:review])
      head :no_content
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review = Review.find(params[:id])
    @review.destroy

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # only permit the trusted paramsters
    def review_params
      params.require(:review).permit(:body, :customer_id)
    end

    # load customer resources
    def load_reviewer
      if params[:user_id]
        @reviewer = User.find(params[:user_id])
      else
        @reviewer = @current_user
      end
    end

end
