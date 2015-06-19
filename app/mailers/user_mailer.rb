class UserMailer < ApplicationMailer

  def new_user(user)
    @user = user

    mail(to: admin_users.join(','),
    subject: 'New User Joined Vicinity') do |format|
      format.html { render 'users/emails/new_user.html.erb' }
    end
  end

  def welcome(user)
  	@user = user

    mail(to: user.email,
    subject: 'Welcome to Vicinity') do |format|
      format.html { render 'users/emails/welcome.html.erb' }
    end
  end

end