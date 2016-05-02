#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-10 22:37:38
# @Last Modified by:   mover
# @Last Modified time: 2016-03-30 15:02:08

require 'net/http'
require 'net/https'
require 'open-uri'

class Utility

	def self.to_boolean(s)
	  s and !!s.match(/^(true|t|yes|y|1)$/i)
	end

	def self.is_facebook_token_valid? token
		res = Utility.http_get(Settings.facebook.graph_api.profile, { :access_token => token})
		return res.code == '200'
	end

	def self.http_get(url, params)
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = uri.scheme == 'https' ? true : false
		headers = {'Content-Type'=> 'application/x-www-form-urlencoded'}
		uri.query = URI.encode_www_form(params) 
		http.request Net::HTTP::Get.new(uri.request_uri)
	end

	def self.log_exception e, args
		extra_info = args[:info]

		Rails.logger.error extra_info if extra_info
		Rails.logger.error e.message
		Rails.logger.error e.backtrace.join("\n")

		extra_info ||= "<NO DETAILS>"
		request = args[:request]
		env = request ? request.env : nil
		if env
			ExceptionNotifier::Notifier.exception_notification(env, e, :data => {:message => "Exception: #{extra_info}"}).deliver_now
   		else
      		ExceptionNotifier::Notifier.background_exception_notification(e, :data => {:message => "Exception: #{extra_info}"}).deliver_now
     	end
	end
end