#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-14 01:13:38
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-21 02:34:20

# module Voteable
# 
# this module could be included in any
# controller that handle vote and unvote logic
# 
module VoteableActions
	extend ActiveSupport::Concern
	
	class_variable_set(:@@before_callbacks, [])
	class_variable_set(:@@voteable, nil)
	
	def vote_up
		puts "GET CALLED #{ self.class.class_variable_get(:@@voteable)}"
		self.class.class_variable_get(:@@before_callbacks).each {|cb| send(cb) }

		if current_user.liked? get_variable_voteable
			current_user.unlike get_variable_voteable
		else
			current_user.like get_variable_voteable
		end	
		render :json => {
				likes: get_variable_voteable.likes
			}, :status => 200
	end

	def vote_down
		self.class.class_variable_get(:@@before_callbacks).each {|cb| send(cb) }
		if current_user.disliked? get_variable_voteable
			current_user.undislike get_variable_voteable
		else
			current_user.dislike get_variable_voteable
		end	
		render :json => {
				likes: get_variable_voteable.dislikes
			}, :status => 200
	end

	def likes	
	end

	def dislkes
	end

	private
	def get_variable_voteable
		instance_variable_get(:"@#{@@voteable.to_s}")
	end

	module ClassMethods
		def before_vote(actions)
			self.class_variable_set(:@@before_callbacks, actions)
			# @@before_callbacks = actions
		end

		def voteable(resource)
			self.class_variable_set(:@@voteable, resource)
			# @@voteable = resource
		end

		def get_variable
			@@voteable
		end
	end
end