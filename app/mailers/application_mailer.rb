class ApplicationMailer < ActionMailer::Base
  default from: 'info@vicinity.deals'

  def admin_users
  	ENV['ADMIN_USERS'].split(',')
  end

end