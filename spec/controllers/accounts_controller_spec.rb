#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 00:40:56
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-13 02:31:22

require 'spec_helper'
require "rails_helper"

RSpec.describe V1::AccountsController, :type => :controller do

	describe  "# POST /signin/facebook" do
		it "sign with invalid token should return HTTP 400 code" do
			post "signin_with_facebook", :id => "dingxizhengdeid",
			                            :name => "dingxizheng", 
			                            :email => "dingxizheng@gmail.com", 
			                            :provider_access_token => "ffwjfowj;fjwfui23ofyi23y32ir", 
			                            :provider => "facebook", 
			                            :expire_at => Date.new + 2.weeks,
			                            :profile_picture => "i am the picture"
			puts response.body
		end
	end

end