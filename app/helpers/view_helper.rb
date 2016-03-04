#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 18:22:32
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-25 15:03:29

module ViewHelper

	# converts a standard url helper method to a versionfied one
	# 
	# For converting 'user_url' to a versionfied
	# 	
	# 	resource_path_to('user_url', user1) #=> v1_user_url(user1)
	# 
	def resource_path_to(function_name, resource)
		namespace = controller_path.split('/').first
		if namespace.size > 1
			send("#{namespace}_#{function_name}".to_sym, resource)
		else
			send("#{function_name}".to_sym, resource)
		end
	end

	def render_partial(json, partial_file, params)
		namespace = controller_path.split('/').first
		json.partial! :partial => "#{namespace}/#{partial_file}", :locals => params
	end

	def render_partial_small(json, model_name, resource)
		namespace = controller_path.split('/').first
		json.partial! partial: "#{namespace}/#{model_name.to_s.downcase}s/#{model_name.to_s.downcase}_small", :locals => { model_name.to_s.downcase.to_sym => resource }
	end

	def resource_distance(resource)
		if resource.respond_to?("distance_to") and resource.coordinates.present? and get_location.present? && get_location[:lat].present?
			resource.distance_to([get_location[:lat], get_location[:long]]) * 1.60934
		else
			-1
		end
	end

	def get_current_user
		current_user
	end

	def render_user_avatar(json, user)
		if user.avatar.nil?
			json.image_url user.get_avatar
			json.thumb_url user.get_avatar
		else 
			render_image(json, user.avatar)	
		end
	end

	def render_image(json, image)
		if image.file.present?
			json.id image.get_id
			json.image_url "http://#{ENV['HOST']}/origin/#{image.file.url}"
			if image.file.thumb.present?
				json.thumb_url "http://#{ENV['HOST']}/thumb/#{image.file.thumb.url}"
			end
			if image.file.tiny_thumb.present?
				json.tiny_thumb_url "http://#{ENV['HOST']}/tiny/#{image.file.tiny_thumb.url}"
			end
		end 
	end
end