#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-18 17:26:05
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-18 18:48:23

module FollowableActions
	extend ActiveSupport::Concern
	
	class_variable_set(:@@before_callbacks, [])
	class_variable_set(:@@followable, nil)
	class_variable_set(:@@after_follow, nil)
	class_variable_set(:@@after_unfollow, nil)
	
	def follow
		self.class.class_variable_get(:@@before_callbacks).each {|cb| send(cb) }
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
		self.class.class_variable_get(:@@before_callbacks).each {|cb| send(cb) }
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

	# write my own followable should be searchable
	def followers
		users = get_followable.all_followers
		render_json "users/users", :locals => { :users => users }
	end

	private
	def get_followable
		instance_variable_get(:"@#{@@followable.to_s}")
	end

	module ClassMethods
		def before_follow(actions)
			self.class_variable_set(:@@before_callbacks, actions)
			# @@before_callbacks = actions
		end

		def followable(resource)
			self.class_variable_set(:@@followable, resource)
			# @@voteable = resource
		end

		def after_follow(method)
			self.class_variable_set(:@@after_follow, method)
		end

		def after_unfollow(method)
			self.class_variable_set(:@@after_unfollow, method)
		end
	end
end