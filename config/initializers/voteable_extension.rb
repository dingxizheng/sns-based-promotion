#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-14 01:13:38
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-14 02:14:27

# module Voteable
# 
# this module could be included in any
# controller that handle vote and unvote logic
# 
module VoteableActions

	def vote_up
		@@before_callbacks.each {|cb| send(cb) }
		current_user.vote(:votee => instance_variable_get(:"@#{@@voteable.to_s}"), value => :up)
		head :no_content
	end

	def vote_down
		@@before_callbacks.each {|cb| send(cb) }
		current_user.vote(:votee => instance_variable_get(:"@#{@@voteable.to_s}"), value => :down)
		head :no_content
	end

	def likes
		
	end

	def dislkes
	end

	module ClassMethods
		def before_vote(actions)
			@@before_callbacks = actions
		end

		def voteable(resource)
			@@voteable = resource
		end
	end

end

