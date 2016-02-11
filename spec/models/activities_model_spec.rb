#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-20 22:03:34
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-10 21:38:24

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

		# ====== subscribables =======
		sub = Subscribable.new
		sub.tags = ["iphone", "pink"]
		# sub.maximum_price = 100
		sub.save

		sub2 = Subscribable.new
		sub2.tags = ["iphone", "dai"]
		sub2.save

		sub3 = Subscribable.new
		sub3.tags = ["green", "dai"]
		sub3.save

		one.follow sub
		one.follow sub2


		# ====== promotions ========
		p1 = two.promotions.build({ :body => "promotion one", :tags => ["iphone", "pink"]})
		two.save
		p1.add_subscribable_activity

		p2 = three.promotions.build({ :body => "promotion two", :parent_id => p1.get_id })
		three.save
		p2.add_subscribable_activity

		p3 = one.promotions.build({ :body => "promotion three" , :tags => ["iphone", "green", "dai"]})
		one.save
		p3.add_subscribable_activity

		p4 = four.promotions.build({ :body => "promotion four", :tags => ["green", "dai"] })
		four.save
		p4.add_subscribable_activity

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

		one = two
		puts "\n===== #{one.name}'s timeline (most recent first)====="
		PublicActivity::Activity.all
		    .or(
		    	{ :owner_id.in => one.followees_by_type("user").map(&:_id) << one.followees_by_type("subscribable").map(&:_id) << one.get_id},
		    	{ :recipient_id => one.get_id }
		    )
		    .order_by(created_at: :desc)
		    .each do |a|
			puts "\n#{a.owner.name} -> \n  key: #{a.key}"
			puts "  trackable: #{ a.trackable.respond_to?("body") ? a.trackable.body : a.trackable.name}"
		end

	end
end