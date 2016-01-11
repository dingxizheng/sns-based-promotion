#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-10 22:37:38
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-10 22:43:37
class Utility

	def self.log_exception e, args
		extra_info = args[:info]

		Rails.logger.error extra_info if extra_info
		Rails.logger.error e.message
		st = e.backtrace.join("\n")
		Rails.logger.error st

		extra_info ||= "<NO DETAILS>"
		request = args[:request]
		env = request ? request.env : nil
		if env
			ExceptionNotifier::Notifier.exception_notification(env, e, :data => {:message => "Exception: #{extra_info}"}).deliver
   		else
      		ExceptionNotifier::Notifier.background_exception_notification(e, :data => {:message => "Exception: #{extra_info}"}).deliver
     	end
	end
end