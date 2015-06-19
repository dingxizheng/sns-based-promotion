class SubscriptionsController < ApplicationController

  before_action :restrict_access, only: [:create, :destory, :cancel]
  before_action :set_subscription, except: [:index, :create]

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    @subscriptions = query_by_conditions(Subscription, request.query_parameters)
    render 'subscriptions/subscriptions', :locals => { :subscriptions => @subscriptions }
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    render :partial => 'subscriptions/subscription', :locals => { :subscription => @subscription }
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)
    
    # check if current user has the right to create a subscription
    authorize @subscription

    # set the product from product id
    @subscription.product = Product.find(product_id[:product_id]).get_hash

    # # set price
    # @subscription.payment = Payment.new({ :amount => @subscription.product[:price] })

    raise UnprocessableEntityError.new(@subscription.errors) unless @subscription.save
    
    render :partial => 'subscriptions/subscription', :locals => { :subscription => @subscription }
  end

  # approve the membership request by using a one time admin token
  # GET /subscriptions/1/approvebyadmintoken
  def approve_by_admin_token
    if Token.find(params[:admin_token]).present?
      @subscription.approve
      raise UnprocessableEntityError.new(@subscription.errors) unless @subscription.save
      Token.find(params[:admin_token]).destroy
      @subscription.start_to_set_expire_status
      @subscription.start_to_set_activate_status
      render :text => 'request has been approved successfully!';
    else
      render :text => 'token expired! the request has been approved already!';
    end
  end

  # GET /subscriptions/1/cancelbyadmintoken
  def cancel_by_admin_token
    if Token.find(params[:admin_token]).present?
      @subscription.cancel
      Token.find(params[:admin_token]).destroy
      raise UnprocessableEntityError.new(@subscription.errors) unless @subscription.save
      render :text => 'request has been cancelled successfully!';
    else
      render :text => 'token expired! the request has been cancelled already!';
    end
  end

  def cancel
    authorize @subscription
    @subscription.cancel
    @subscription.save
    render :partial => 'subscriptions/subscription', :locals => { :subscription => @subscription }
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    authorize @subscription
    @subscription.destroy
    head :no_content
  end

  private

    def subscription_params
      params.require(:subscription).permit(:user_id)
    end

    def product_id
      params.require(:subscription).permit(:product_id)
    end

    def set_subscription
      @subscription = Subscription.find(params[:id] || params[:subscription_id])
      raise NotfoundError.new('Subscription', { id => params[:id] || params[:subscription_id] }.to_s ) unless @subscription
    end

end