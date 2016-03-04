#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 22:03:40
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-03-03 20:38:24

class V1::FeedsController < ApplicationController

	before_action :restrict_access, only: [:timeline]
	
	# GET /feeds
	def timeline

		@activities = PublicActivity::Activity.all
		    .or(
		    	{ :owner_id.in => current_user.followees_by_type("user").map(&:_id) + current_user.followees_by_type("subscribable").map(&:_id) + [current_user.get_id]},
		    	{ :recipient_id => current_user.get_id }
		    )
		    .query_by_params(query_params)
		    .query_by_text(search)
		    .sortby('-created_at')
		    .paginate(page, per_page)

	

		render_json "feeds/feeds", :locals => { :activities => @activities }
	end

end