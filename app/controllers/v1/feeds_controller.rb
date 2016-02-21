#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 22:03:40
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-20 22:27:57

class V1::FeedsController < ApplicationController

	before_action :restrict_access, only: [:timeline]
	
	# GET /feeds
	def timeline
		@activities = PublicActivity::Activity.all
			.where( :key.in => ["promotion.created", "user.made_comment", "promotion.reposted"] )
		    .or(
		    	{ :owner_id.in => current_user.followees_by_type("user").map(&:_id) << current_user.followees_by_type("subscribable").map(&:_id) << current_user.get_id},
		    	{ :recipient_id => current_user.get_id }
		    )
		    .order_by(:created_at => :desc)
		render_json "feeds/feeds", :locals => { :activities => @activities }
	end

end