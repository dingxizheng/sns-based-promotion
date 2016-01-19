#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-17 15:12:01
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-18 17:24:56

require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::CommentsController, :type => :controller do
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

		it "wangtong wants to comment daixiaochuan, and xiaochuan wangtong replys himself" do
		 
			# create a session for wangtong
			session = tong.sessions.build()
			session.save!

			post :create,  :user_id => dai.get_id, 
						   :access_token => session.access_token,
						   :body => "he is so good!"


			parent_id = JSON.parse(response.body)[:id.to_s]

			post :create,  :user_id => dai.get_id, 
						   :access_token => session.access_token,
						   :body => "he is good tooooooo!",
						   :parent_id => parent_id

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("201")

			post :create,  :user_id => dai.get_id, 
						   :body => "he is good tooooooo!",
						   :parent_id => parent_id
						   
			expect(response.code).to eq("401")
		end

		it "return a list of comments of current resource" do
			c1 = tong.comments.build({
					:body => "hello!!! i am tong",
					:commenteer_id => dai.get_id
				})
			c1.save

			c2 = tong.comments.build({
					:body => "hello!!! i am tong2",
					:commenteer_id => dai.get_id,
					:parent_id => c1.get_id
				})
			c2.save

			get :index, :user_id => tong.get_id

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(JSON.parse(response.body).map {|r| r["id"] }).to eq([c1.get_id, c2.get_id])

			get :index, :user_id => tong.get_id,
						:parent_id => c1.get_id

			expect(JSON.parse(response.body).map {|r| r["id"] }).to eq([c2.get_id])

			request.headers["sortBy"] = "-body"
			get :index, :user_id => tong.get_id			
			expect(JSON.parse(response.body).map {|r| r["id"] }).to eq([c2.get_id, c1.get_id])
		end

		it "like a comment" do
			c1 = tong.comments.build({
					:body => "hello!!! i am tong",
					:commenteer_id => dai.get_id
				})
			c1.save

			session = dai.sessions.build()
			session.save!

			post :vote_up, :user_id => tong.get_id,
						   :comment_id => c1.get_id,
						   :access_token => session.access_token 

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(JSON.parse(response.body)["likes"]).to eq(1)
		end
	end
end