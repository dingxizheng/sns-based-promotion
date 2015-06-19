class ApplicationMailer < ActionMailer::Base
  default from: "donotreply@example.com"

  def admin_users
  	['dingxizheng@gmail.com']
  end 

end