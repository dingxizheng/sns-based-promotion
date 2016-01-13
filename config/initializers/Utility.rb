#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-10 22:37:38
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-12 19:08:43

require 'net/http'
require 'net/https'
require 'open-uri'

class Utility

	def self.is_facebook_token_valid? token
		res = Utility.http_get(Settings.facebook.graph_api.profile, { :access_token => token})
		return res.code == '200'
	end

	def self.http_get(url, params)
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		if uri.scheme == 'https'
			http.use_ssl = true
		end
		headers = {'Content-Type'=> 'application/x-www-form-urlencoded'}
		uri.query = URI.encode_www_form(params)
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		response
	end

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