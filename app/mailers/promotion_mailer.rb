class PromotionMailer < ApplicationMailer

  def notify_admin(promotion)
    @promotion = promotion

    @approve_link = promotion_url(promotion) + '/approvebyadmintoken?admin_token=' + Token.create.get_id
    @cancel_link = promotion_url(promotion) + '/cancelbyadmintoken?admin_token=' + Token.create.get_id

    mail(to: receivers(admin_users),
    subject: 'New Promotion Request') do |format|
      format.html { render 'promotions/emails/request.html.erb' }
    end
  end

  def reported_to_admin(promotion, reason)
  	@reason = reason
  	@promotion = promotion
  	@reject_link = promotion_url(promotion) + '/cancelbyadmintoken?admin_token=' + Token.create.get_id

  	mail(to: receivers(admin_users), 
  	subject: 'Promotion Reported') do |format|
  		format.html { render 'promotions/emails/report.html.erb' }
  	end
  end

  def notification_request(promotion)
    @promotion = promotion
    @approve_link = promotion_url(promotion) + '/notifybyadmintoken?admin_token=' + Token.create.get_id

    mail(to: receivers(admin_users), 
    subject: 'Notification Request') do |format|
      format.html { render 'promotions/emails/notification.html.erb' }
    end
  end

end
