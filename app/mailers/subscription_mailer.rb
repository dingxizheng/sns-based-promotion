class SubscriptionMailer < ApplicationMailer

  def notify_admin(subscription)
    @subscription = subscription
    @approve_link = subscription_url(subscription) + '/approvebyadmintoken?admin_token=' + Token.create.get_id
    @cancel_link = subscription_url(subscription) + '/cancelbyadmintoken?admin_token=' + Token.create.get_id
    
    mail(to: admin_users.join(','),
    subject: 'MemberShip Request') do |format|
      format.html { render 'subscriptions/emails/request.html.erb' }
    end
  end

end