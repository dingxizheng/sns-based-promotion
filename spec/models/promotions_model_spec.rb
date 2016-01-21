#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-19 13:06:23
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-20 22:02:27
require "rails_helper"
require 'database_cleaner'
DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe Promotion, :type => :model do
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

	it "create a new promotion" do
		promotion = dai.promotions.build({
				:body => "this is so great!!!!"
			})

		dai.save

		expect(promotion.body).to eq("this is so great!!!!")
		expect(promotion.parent).to be_nil
	end

	it "tong reposts dai's promotion" do
		promotion = dai.promotions.build({
				:body => "this is so great!!!!"
			})
		dai.save

		repost = tong.promotions.build({
				:body => "dai is so right",
				:parent_id => promotion.get_id
			})
		tong.save

		repost2 = tong.promotions.build({
				:body => "tong is right",
				:parent_id => repost.get_id
			})
		tong.save

		expect(repost.body).to eq("dai is so right")
		expect(repost.parent).to eq(promotion)
		expect(repost.root).to eq(promotion)

		expect(repost2.parent).to eq(repost)
		expect(repost2.root).to eq(promotion)

		expect(repost2.ancestors[0]).to eq(promotion)
		expect(repost2.ancestors[1]).to eq(repost)

		expect(promotion.reposts[0]).to eq(repost)
		expect(repost.reposts[0]).to eq(repost2)

		expect(promotion.leaves).to eq([repost, repost2])
	end

	# it "tong comments on dai's promotion" do
	# 	# dai makes a promotion
	# 	promotion = dai.promotions.build({
	# 			:body => "this is so great!!!!"
	# 		})
	# 	dai.save

	# 	# tong reposts dai's promotion
	# 	repost = tong.promotions.build({
	# 			:body => "dai is so right",
	# 			:parent_id => promotion.get_id
	# 		})
	# 	tong.save

	# 	# dai makes a comment on tong's repost
	# 	comment = repost.comments.build({
	# 			:body => "this is a very good comment",
	# 			:commenteer_id => dai.get_id
	# 		})
	# 	repost.save

	# 	# now the repost should have a comment that matches the comment dai just create
	# 	expect(repost.comments.find(comment.get_id).body).to eq("this is a very good comment")

	# 	# dai should have the comment he has made
	# 	expect(dai.opinions.find(comment.get_id).body).to eq("this is a very good comment")

	# 	# dai should not have any comments that is made on himself
	# 	expect(dai.comments.find(comment.get_id)).to be_nil
	# end

	it "create promotions should generate activities" do
		promotion = dai.promotions.build({
				:body => "this is so great!!!!"
			})
		dai.save

		repost = tong.promotions.build({
				:body => "dai is so right",
				:parent_id => promotion.get_id
			})
		tong.save

		repost2 = tong.promotions.build({
				:body => "tong is right",
				:parent_id => repost.get_id
			})
		tong.save

		puts "activities: #{PublicActivity::Activity.all[1].to_yaml}"
	end
end