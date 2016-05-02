#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-18 17:26:05
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-03-27 23:43:52

module FollowableActions
	extend ActiveSupport::Concern
	
	def follow
		if current_user.nil?
			raise MyError.new(500, "current user is not found, please make sure that method :current_user is defined and it returns the current user")
		else
			current_user.follow get_followable
			if self.class.class_variable_get(:@@after_follow).present?
				send(self.class.class_variable_get(:@@after_follow))
			else
				render :json => {}, :status => 200
			end
		end
	end

	def unfollow
		if current_user.nil?
			raise MyError.new(500, "current user is not found, please make sure that method :current_user is defined and it returns the current user")
		else
			current_user.unfollow get_followable
			if self.class.class_variable_get(:@@after_unfollow).present?
				send(self.class.class_variable_get(:@@after_unfollow))
			else
				render :json => {}, :status => 200
			end
		end
	end

	def friendship
		if current_user.nil?
			raise MyError.new(500, "current user is not found, please make sure that method :current_user is defined and it returns the current user")
		else
			render :json => {
				follower: current_user.follower_of?(get_followable),
				followee: current_user.followee_of?(get_followable)
			}
		end
	end

	# write my own followable should be searchable
	def followers
		users = get_followable.all_followers
		render_json "users/users", :locals => { :users => users }
	end

	def followees
		if get_followable.respond_to? "all_followees"
			users = get_followable.all_followees
			render_json "users/users", :locals => { :users => users }
		else
			render_json "users/users", :locals => { :users => [] }
		end
	end

	private
	def get_followable
		instance_variable_get(:"@#{self.class.followable_object.to_s}")
	end

	module ClassMethods
		def before_follow(actions)
			# self.class_variable_set(:@@before_callbacks, actions)
			# @@before_callbacks = actions
		end

		def followable(resource)
			@followable_object = resource
			# @@voteable = resource
		end

		def followable_object
			@followable_object
		end

		def after_follow(method)
			# self.class_variable_set(:@@after_follow, method)
		end

		def after_unfollow(method)
			# self.class_variable_set(:@@after_unfollow, method)
		end
	end
end