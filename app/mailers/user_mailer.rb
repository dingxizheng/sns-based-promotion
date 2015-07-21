class UserMailer < ApplicationMailer

  def new_user(user)
    @user = user

    mail(to: admin_users.join(','),
    subject: 'New User Joined Vicinity Deals') do |format|
      format.html { render 'users/emails/new_user.html.erb' }
    end
  end

  def welcome(user)
  	@user = user

    mail(to: user.email,
    subject: 'Welcome to Vicinity Deals') do |format|
      format.html { render 'users/emails/welcome.html.erb' }
    end
  end

  def reset_password(user)
    @user = user
    @reset_link = user_url(user) + '/resetpasswordbytoken?admin_token=' + Token.create.get_id

    mail(to: admin_users.join(','),
    subject: 'Password Reset Request') do |format|
      format.html { render 'users/emails/reset_password_request.html.erb' }
    end
  end

  def new_password(user, password)
    @user = user
    @password = password

    mail(to: 'dingxizheng@gmail.com',
    subject: 'Your New Password') do |format|
      format.html { render 'users/emails/new_password.html.erb' }
    end
  end

end