class ApplicationMailer < ActionMailer::Base
  default from: 'Vicinity Deals <info@vicinity.deals>'

  def admin_users
  	ENV['ADMIN_USERS'].split(',')
  end

  def receivers(emails)
  	if Rails.env.test?
  		emails << 'dingxizheng@gmail.com'
  	else
  		emails
  	end
  	emails.join(',')
  end

end