class ReviewsController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :load_reviewer

  # GET /reviews
  # GET /reviews.json
  def index
    if @reviewee
      render 'reviews/reviews', :locals => { :reviews => @reviewee.reviews }
    elsif @reviewer
      render 'reviews/reviews', :locals => { :reviews => @reviewer.opinions }
    else 
      render 'reviews/reviews', :locals => { :reviews => Review.all }
    end

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
    raise UnprocessableEntityError.new(@review.errors) unless @review.save
    render :partial => 'reviews/review', :locals => { :review => @review }, status: :created

  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    raise UnprocessableEntityError.new(@review.errors) unless @review.update(params[:review])     
    render :partial => 'reviews/review', :locals => { :review => @review }

  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
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
        @reviewee = User.find(params[:user_id])
      else
        @reviewer = @current_user
      end
      @reviewer = @current_user
    end

end
