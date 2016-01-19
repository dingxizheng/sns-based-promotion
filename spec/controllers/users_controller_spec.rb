#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-16 15:59:09
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-18 21:46:35

require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::UsersController, :type => :controller do
	render_views
	
	describe  "# GET /users" do
		before(:each) {
			DatabaseCleaner.start
		}

		after(:each) {
			DatabaseCleaner.clean
		}

		let(:dai) {
			dai = User.create({
					:name => "daixiaochuan2",
					:email => "daixiaochuan2@gmail.com",
					:phone => "8076319946",
					:description => "this is daixiaochuan2",
					:password => "yuan1234"
				})
			dai.save
			dai
		}

		let(:tong) {
			tong = User.create({
					:name => "wangtong",
					:email => "wangtong@gmail.com",
					:phone => "8076319947",
					:description => "this is wangtong, i am so good",
					:password => "tong1234"
				})
			tong.save
			tong
		}
		
		it "return one user" do	
			get :show, :id => dai.get_id
			expect(response.body).to include("daixiaochuan2")
			expect(response.body).to include("comments")
			expect(response.body).not_to include("wangtong")	
		end

		it "wang tong wants to like on daixiaochuan" do	
			 
			# create a session for wangtong
			session = tong.sessions.build()
			session.save!

			post :vote_up, :user_id => dai.get_id
			expect(response.code).to eq("401")	

			post :vote_up, :user_id => dai.get_id, 
						   :access_token => session.access_token
						   
			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("200")	
		end

		# it "return users in a list" do	
		# 	get :index
		# 	expect(response.body).to include("daixiaochuan2")
		# 	expect(response.body).to include("wangtong")	
		# end

		it "wang tong wants to tag on daixiaochuan" do			 
			# create a session for wangtong
			session = tong.sessions.build()
			session.save!

			post :tag, :user_id => dai.get_id,
					   :tags => "good;hao;nihao",
					   :access_token => session.access_token

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("200")
			expect(response.body).to include("good")
			expect(response.body).to include("hao")
			expect(response.body).to include("nihao")
		end

		it "wang tong wants to untag on daixiaochuan" do
			# create a session for wangtong
			session = tong.sessions.build()
			session.save!

			post :tag, :user_id => dai.get_id,
					   :tags => "good;hao;nihao",
					   :access_token => session.access_token

			post :untag, :user_id => dai.get_id,
					   :tags => "nihao",
					   :access_token => session.access_token

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("200")
			expect(response.body).to include("good")
			expect(response.body).to include("hao")
		end

		it "wang tong follows daixiaochuan and yuanmiao" do

			three = User.new({
				:name => "yuanmiao",
				:email => "yuanmiao@gmail.com",
				:password => "yuan1234"
			})

			three.save!

			session = tong.sessions.build()
			session.save!

			session2 = three.sessions.build()
			session2.save!

			post :follow, :user_id => dai.get_id,
						  :access_token => session.access_token

			expect(response.code).to eq("200")

			post :follow, :user_id => dai.get_id,
						  :access_token => session2.access_token

			get :followers, :user_id => dai.get_id,
							:access_token => session.access_token

			expect(response.body).to include(tong.get_id)
			expect(response.body).to include(three.get_id)

			post :follow, :user_id => three.get_id

			expect(response.code).to eq("401")

			post :unfollow, :user_id => dai.get_id,
							:access_token => session2.access_token

			get :followers, :user_id => dai.get_id,
							:access_token => session.access_token

			expect(response.body).to include(tong.get_id)
			expect(response.body).not_to include(three.get_id)

		end

		it "wang tong wants to update his profile" do
			session = tong.sessions.build()
			session.save!

			put :update, :id => tong.get_id,
						 :access_token => session.access_token,
						 :name => "dingdada2",
						 :avatar => fixture_file_upload('/Users/mover/Documents/SkyDrive/图片/本机照片/20121001_015204000_iOS.jpg', 'image/jpg'),
						 :background => fixture_file_upload('/Users/mover/Documents/SkyDrive/图片/本机照片/20121001_015204000_iOS.jpg', 'image/jpg')
			
			get :show, :id => tong.get_id
					   # :access_token => session.access_token

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.body).to include("dingdada")
		end
	end
end