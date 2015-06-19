class PromotionMailer < ApplicationMailer

  def notify_admin(promotion)
    @promotion = promotion

    @approve_link = promotion_url(promotion) + '/approvebyadmintoken?admin_token=' + Token.create.get_id
    @cancel_link = promotion_url(promotion) + '/cancelbyadmintoken?admin_token=' + Token.create.get_id

    mail(to: admin_users.join(','),
    subject: 'New Promotion Request') do |format|
      format.html { render 'promotions/emails/request.html.erb' }
    end
  end

end
