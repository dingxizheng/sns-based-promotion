#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-19 15:35:47
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-20 16:24:19

require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::PromotionsController, :type => :controller do
	render_views
	
	describe  "# post /comments" do
		before(:each) {
			DatabaseCleaner.start
		}

		after(:each) {
			DatabaseCleaner.clean
		}

		let(:dai) {
			User.create({
					:name => "daixiaochuan2",
					:email => "daixiaochuan2@gmail.com",
					:phone => "8076319946",
					:description => "this is daixiaochuan2",
					:password => "yuan1234"
				})
		}

		let(:tong) {
			User.create({
					:name => "wangtong",
					:email => "wangtong@gmail.com",
					:phone => "8076319947",
					:description => "this is wangtong, i am so good",
					:password => "tong1234"
				})
		}

		it "wangtong wants to make a promotion" do
		 
			# create a session for wangtong
			session = tong.sessions.build()
			session.save!

			session2 = dai.sessions.build()
			session2.save!

			# tong creates a promotion
			post :create,  :user_id => tong.get_id, 
						   :access_token => session.access_token,
						   :body => "this is tong's post!",
						   :tags => ["tong", "dai"]


			post_id = JSON.parse(response.body)["id"]
			# puts JSON.pretty_generate(JSON.parse(response.body))

			# dai reposts tong's promotion
			post :create, :user_id => dai.get_id,
						  :access_token => session2.access_token,
						  :body => "this is a repost of tong's post",
						  :parent_id => post_id

			repost_id = JSON.parse(response.body)["id"]

			# dai reposts the promotion he just reposted
			post :create, :user_id => dai.get_id,
						  :access_token => session2.access_token,
						  :body => "this is another repost of tong's post",
						  :parent_id => repost_id

			repost2_id = JSON.parse(response.body)["id"]

			# puts JSON.pretty_generate(JSON.parse(response.body))		   
			expect(response.code).to eq("201")

			get :index, :root_id => post_id
			# puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.body).to include("this is a repost of tong's post")

			# should be able to get two reposts of the original one
			get :reposts, :promotion_id => post_id
			expect(JSON.parse(response.body).count).to eq(1)

			get :ancestors, :promotion_id => repost2_id
			expect(JSON.parse(response.body).count).to eq(2)
		end

		it "uploading photos together with a post" do
			session = tong.sessions.build()
			session.save!

			# tong creates a promotion
			post :create,  :user_id => tong.get_id, 
						   :access_token => session.access_token,
						   :body => "here we go. we love thunderbay",
						   :tags => ["tong", "dai"],
						   :photos => [fixture_file_upload('/Users/mover/Documents/SkyDrive/图片/本机照片/20121001_015204000_iOS.jpg', 'image/jpg'), fixture_file_upload('/Users/mover/Documents/SkyDrive/图片/本机照片/20121001_015204000_iOS.jpg', 'image/jpg')]
			
			post :create,  :user_id => tong.get_id, 
						   :access_token => session.access_token,
						   :body => "this is wefwe's!",
						   :tags => ["dai", "root"]			

			post_id = JSON.parse(response.body)["id"]

			get :index, :body => "here we go. we love thunderbay&&this is wefwe's!"
			puts JSON.pretty_generate(JSON.parse(response.body))

			# expect(response.body).to include("20121001_015204000_iOS")
		end

	end
end