#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-02-10 20:45:56
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-10 21:09:07

require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::SubscribablesController, :type => :controller do
	render_views
	
	describe  "SubscribableController" do
		before(:each) {
			DatabaseCleaner.start
		}

		after(:each) {
			DatabaseCleaner.clean
		}

		let(:dai) {
			dai = User.new({
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
			tong = User.new({
					:name => "wangtong",
					:email => "wangtong@gmail.com",
					:phone => "8076319947",
					:description => "this is wangtong, i am so good",
					:password => "tong1234"				
				})
			tong.save
			tong
		}
		
		it "return subscribable item list" do
			sub = Subscribable.new
			sub.tags = ["iphone", "pink"]
			sub.maximum_price = 100
			sub.save

			sub2 = Subscribable.new
			sub2.tags = ["iphone", "daio"]
			sub2.save

			get :index

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("200")
		end

		it "return one subscribable item" do
			sub = Subscribable.new({
					:tags => ["iphone", "good"],
					:name => "i want a iphone",
					:maximum_price => 100,
					:user_id => tong.get_id
				})

			sub.save

			get :show, :id => sub.get_id

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("200")
		end

		it "create a sub should return 201 code" do
			session = tong.sessions.build()
			session.save!

			post :create, :tags => ["iphone", "good"],
						  :name => "i want a iphone",
						  :maximum_price => 100,
						  :minimum_price => 20,
						  :access_token => session.access_token

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("201")
		end
	end
end