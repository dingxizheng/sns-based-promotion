class ExceptionMailer < ApplicationMailer

  def exception_report(exception)
    @user = user

    mail(to: admin_users.join(','),
    subject: 'New User Joined Vicinity Deals') do |format|
      format.html { render 'users/emails/new_user.html.erb' }
    end
  end

end