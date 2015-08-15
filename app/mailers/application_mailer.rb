class ApplicationMailer < ActionMailer::Base
  default from: "donotreply@example.com"

  def admin_users
  	ENV['ADMIN_USERS'].split(',')
  end

end