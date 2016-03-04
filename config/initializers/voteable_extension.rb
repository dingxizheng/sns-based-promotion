#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-14 01:13:38
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-03-03 23:22:26

# module Voteable
# 
# this module could be included in any
# controller that handle vote and unvote logic
# 
module VoteableActions
	extend ActiveSupport::Concern
	
	
	def vote_up

		if current_user.liked? get_variable_voteable
			current_user.unlike get_variable_voteable
			render :json => {
				operation: -1,
				likes: get_variable_voteable.likes
			}, :status => 200
		else
			current_user.like get_variable_voteable
			render :json => {
				operation: 1,
				likes: get_variable_voteable.likes
			}, :status => 200
		end
	end

	def vote_down

		if current_user.disliked? get_variable_voteable
			current_user.undislike get_variable_voteable
			render :json => {
				operation: -1,
				likes: get_variable_voteable.dislikes
			}, :status => 200
		else
			current_user.dislike get_variable_voteable
			render :json => {
				operation: 1,
				likes: get_variable_voteable.dislikes
			}, :status => 200
		end	
	end

	def likers
		if get_variable_voteable.present?
			@likers = get_variable_voteable.likers
					  					.sortby(sortBy)
	                  					.paginate(page, per_page)

	        render_json "users/users", :locals => { :users => @likers }
	    else
	    	render :json => []
	    end
	end

	def dislkers
		if get_variable_voteable.present?
			@dislikers = get_variable_voteable.dislkers
					  					.sortby(sortBy)
	                  					.paginate(page, per_page)

	        render_json "users/users", :locals => { :users => @dislikers }
        else
	    	render :json => []
	    end
	end

	private
	def get_variable_voteable
		instance_variable_get(:"@#{self.class.voteable_object.to_s}")
	end

	module ClassMethods

		def before_vote(actions)
			# self.voteable_object
			# self.class_variable_set(:@@before_callbacks, actions)
			# @@before_callbacks = actions
		end

		def voteable(resource)
			@voteable_object = resource;
		end

		def voteable_object
			@voteable_object
		end

		def get_variable
			@@voteable
		end
	end
end