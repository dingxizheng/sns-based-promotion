#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 00:40:56
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-14 00:54:23

require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::AccountsController, :type => :controller do
	render_views
	
	describe  "# POST /signin/facebook" do
		it "sign with invalid token should return HTTP 400 code" do
			DatabaseCleaner.start
			post "signin_with_facebook", :id => "dingxizhengdeid",
			                            :name => "dingxizheng", 
			                            :email => "dingxizheng@gmail.com", 
			                            :provider_access_token => "ffwjfowj;fjwfui23ofyi23y32ir", 
			                            :provider => "facebook", 
			                            :expire_at => Date.new + 2.weeks,
			                            :profile_picture => "i am the picture"
			
			expect(response.body).to include("dingxizheng")
			DatabaseCleaner.clean
		end
	end

end