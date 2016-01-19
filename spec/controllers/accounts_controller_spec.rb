#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 00:40:56
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-16 20:09:34

require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::AccountsController, :type => :controller do
	render_views
	
	describe  "# /accounts " do
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

  describe  "# POST /signup" do
    before(:all) { @access_token = "" }
    DatabaseCleaner.start
    it "signup successfully should return user in json" do
      post "signup_with_email",   :name => "yuanmiao", 
                                  :email => "yuanmiao@gmail.com", 
                                  :password => "12345Kobe"
      

      puts JSON.pretty_generate(JSON.parse(response.body))
      expect(response.code).to eq("201")
      expect(response.body).to include("yuanmiao")
      expect(response.body).not_to include("yuanmiao@gmail.com")
    end

    it "signin failed should return error message" do
      post "signin", :email => "yuanmiao@gmail.com",
                     :password => "23ewew"
      expect(response.code).to eq("400")
      expect(response.body).to include("the credentidals do not match our records")
    end

    it "get /me without login should fail" do
      get "me"
      expect(response.code).not_to eq("200")
      expect(response.body).not_to include("yuanmiao")
    end

    it "signin successfully should return access token" do
      post "signin", :email => "yuanmiao@gmail.com",
                     :password => "12345Kobe"

      expect(response.code).to eq("200")
      expect(response.body).to include("access_token")
    end

    it "signin successfully should return access token" do
      post "signin", :email => "yuanmiao@gmail.com",
                     :password => "12345Kobe"

      expect(response.code).to eq("200")
      expect(response.body).to include("access_token")
    end

    it "get /me should return user profile data" do

      post "signin", :email => "yuanmiao@gmail.com",
                     :password => "12345Kobe"

      @access_token = JSON.parse(response.body)[:access_token.to_s]

      puts @access_token
      get "me", :access_token => @access_token
      expect(response.body).to include("yuanmiao")
    end

    DatabaseCleaner.clean
  end

end