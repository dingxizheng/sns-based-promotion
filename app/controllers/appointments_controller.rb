class AppointmentsController < ApplicationController

  before_action :restrict_access, only: [:create, :update, :destory]
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :set_user, except: []

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = PromotionPolicy::Scope.new(@user, Review).resolve
    render 'reviews/reviews', :locals => { :reviews => @reviews }
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    render :partial => 'reviews/review', :locals => { :review => @review }
  end

  # POST /appointments
  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.accepter = @accepter
    @appointment.booker = @booker

    authorize @appointment
    moderatorize review.reviewer, @review

    raise UnprocessableEntityError.new(@appointment.errors) unless @appointment.save
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
  def appointment_params
    params.require(:appointment).permit(:text, :start_at, :end_at)
  end

  # set the appointment accepter
  def set_accepter
    if params[:user_id]
      @accepter = User.find(params[:user_id])
    end
  end

  # set appointment booker
  def set_booker
    @booker = current_user
  end

end
