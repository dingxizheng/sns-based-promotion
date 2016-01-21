#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-20 22:03:34
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-21 00:13:02

require "rails_helper"
require 'database_cleaner'
DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.describe PublicActivity::Activity, :type => :model do
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

		puts "\n#{one.name} is followed by #{ one.all_followers.map(&:name).join("::") }"
		puts "#{one.name} is following by #{ one.all_followees.map(&:name).join("::") }"

		puts "expect #{one.name} to have 1 followers"
		expect(one.followers_count).to eq(1)
		puts "expect #{one.name} to have 2 followees"
		expect(one.followees_count).to eq(2)
	end

	it "friends activities should be viewable to user" do
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

		four = User.new({
				:name => "youmeng",
				:email => "youmeng@gmail.com",
				:password => "youmeng1234"
			})

		one.save!
		two.save!
		three.save!
		four.save!

		one.follow(two)
		one.follow(three)
		three.follow(one)

		# ====== promotions ========
		p1 = two.promotions.build({ :body => "promotion one"})
		two.save

		p2 = three.promotions.build({ :body => "promotion two", :parent_id => p1.get_id })
		three.save

		p3 = one.promotions.build({ :body => "promotion three" })
		one.save

		p4 = four.promotions.build({ :body => "promotion four" })
		four.save

		# ====== comments ========
		c1 = p1.comments.build({
				:body => "you are a nice man",
				:commenteer_id => two.get_id
			})
		c1.save

		c2 = p3.comments.build({
				:body => "a comment on promotion three",
				:commenteer_id => four.get_id
			})
		c2.save

		three.update({ :name => "yuanmiao @@" })

		puts "\n===== #{one.name}'s timeline (most recent first)====="
		PublicActivity::Activity.all
		    .or(
		    	{ :owner_id.in => one.followees_by_type("user").map(&:_id) << one.get_id },
		    	{ :recipient_id => one.get_id }
		    )
		    .order_by(created_at: :desc)
		    .each do |a|
			puts "\n#{a.owner.name} -> \n  key: #{a.key}"
			puts "  trackable: #{ a.trackable.respond_to?("body") ? a.trackable.body : a.trackable.name}"
		end

	end
end