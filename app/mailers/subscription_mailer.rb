class SubscriptionMailer < ApplicationMailer

  def notify_admin(subscription)
    @subscription = subscription
    @approve_link = subscription_url(subscription) + '/approvebyadmintoken?admin_token=' + subscription.admin_token_for_approval
    @cancel_link = subscription_url(subscription) + '/cancelbyadmintoken?admin_token=' + subscription.admin_token_for_cancellation
    
    mail(to: 'dingxizheng@gmail.com',
    subject: 'MemberShip Request') do |format|
      format.html { render 'subscriptions/emails/request.html.erb' }
    end
  end

end
