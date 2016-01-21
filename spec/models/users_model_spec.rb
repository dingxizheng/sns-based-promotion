#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-17 14:35:06
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-21 02:25:08


require "rails_helper"
require 'database_cleaner'
DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe User, :type => :model do
	before(:each) {
		DatabaseCleaner.start
	}
	after(:each) {
		DatabaseCleaner.clean
	}

	it "user one follows user two" do
		one = User.new({
				:name => "daixiaochuan",
				:email => "daixiaochuan@gmail.com",
				:password => "dai1234"
			})

		two = User.new({
				:name => "dingxizheng",
				:email => "dingxizheng@gmail.com",
				:password => "ding1234"
			})

		three = User.new({
				:name => "yuanmiao",
				:email => "yuanmiao@gmail.com",
				:password => "yuan1234"
			})

		one.save!
		two.save!
		three.save!

		one.follow(two)
		one.follow(three)

		three.follow(one)

		expect(one.follower_of?(two)).to be true
		expect(two.followee_of?(one)).to be true

		puts one.all_followers.map(&:name).join("::")
		puts one.all_followees.map(&:name).join("::")

		expect(one.followers_count).to eq(1)
		expect(one.followees_count).to eq(2)
	end

	it "add comments to user" do
		one = User.new({
				:name => "daixiaochuan",
				:email => "daixiaochuan@gmail.com",
				:password => "dai1234"
			})

		two = User.new({
				:name => "dingxizheng",
				:email => "dingxizheng@gmail.com",
				:password => "ding1234"
			})

		one.save
		two.save

		# one.tags = ["ding", "dai"]

		tag1 = Tag.create({:body => "miao"})
		tag2 = Tag.create({:body => "meng"})

		one.tags = [tag1, tag2]

		two.add_tags [tag2]

		one.remove_tags [tag2]

		puts "tags: #{ User.all[0].tag_objects.map(&:body).join("#") }"
	end

	it "add avatar to user" do
		one = User.new({
				:name => "daixiaochuan",
				:email => "daixiaochuan@gmail.com",
				:password => "dai1234"
			})

		image = Image.create({
				:file => File.open("/Users/mover/Documents/SkyDrive/图片/本机照片/20121001_015204000_iOS.jpg")
			})

		one.set_photos [image.get_id, File.open("/Users/mover/Documents/SkyDrive/图片/本机照片/20121001_015204000_iOS.jpg")]
		one.save	

		expect(one.photos[0]).not_to be nil	
		expect(one.photos[1]).not_to be nil	
	end

	it "test likes" do 
		one = User.new({
				:name => "daixiaochuan",
				:email => "daixiaochuan@gmail.com",
				:password => "dai1234"
			})
		one.save

		two = User.new({
				:name => "wangtong",
				:email => "wangtong@gmail.com",
				:password => "dai1234"
			})
		two.save

		one.like(two)
		expect(User.find(two.get_id).likers.find(one.get_id)).not_to be_nil

		one.unlike(two)
		expect(User.find(two.get_id).likers.find(one.get_id)).to be_nil

		expect(User.find(one.get_id)).not_to be_nil

	end
end