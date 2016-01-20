#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-20 13:05:03
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-20 13:19:05
require 'spec_helper'
require 'rails_helper'
require 'database_cleaner'

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe V1::TagsController, :type => :controller do
	render_views
	
	describe  "# GET /users" do
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
		
		it "get tag info" do

			tong.tags = ["thunderbay"]
			tong.save

			dai.tags = ["thunderbay"]

			dai.promotions.build({
					:body => "this a post of dai",
					:tags => ["thunderbay", "promotins"]
				})

			dai.promotions.build({
					:body => "this a second post of dai",
					:tags => ["thunderbay", "promotins", "hello"]
				})

			dai.save

			get :show, :id => "thunderbay"

			puts JSON.pretty_generate(JSON.parse(response.body))
			expect(response.code).to eq("200")
		end
	end
end