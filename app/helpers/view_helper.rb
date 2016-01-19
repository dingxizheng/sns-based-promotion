#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 18:22:32
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-19 17:26:30

module ViewHelper

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
		if resource.coordinates.present? and geo_location[:lat].present?
			resource.distance_to(geo_location) * 1.60934
		else
			-1
		end
	end

	def render_user_avatar(json, user)
		if user.avatar.nil?
			json.image_url user.avatar.file.url
			json.thumb_url user.avatar.file.thumb.url
		else 
			render_image(json, user.avatar)	
		end
	end

	def render_image(json, image)
		if image.file.present?
			json.id image.get_id
			json.image_url image.file.url
			if image.file.thumb.present?
				json.thumb_url image.file.thumb.url
			end
			if image.file.tiny_thumb.present?
				json.tiny_thumb_url image.file.tiny_thumb.url
			end
		end
	end
end