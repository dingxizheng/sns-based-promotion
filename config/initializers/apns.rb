require 'houston'

class APNS
	if Rails.env.production?
		@@apn = Houston::Client.production
		@@apn.certificate = File.read("certificates/apple_push_notification_production.pem")
	elsif Rails.env.development?
		@@apn = Houston::Client.development
		@@apn.certificate = File.read("certificates/apple_push_notification_development.pem")
	end

	def self.get
		@@apn
	end
end