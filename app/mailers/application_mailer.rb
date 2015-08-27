class ApplicationMailer < ActionMailer::Base
  default from: 'Vicinity Deals <info@vicinity.deals>'

  def admin_users
  	ENV['ADMIN_USERS'].split(',')
  end

end