#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-13 18:22:32
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-14 16:54:19

module ViewHelper
	def resource_path_to(function_name, resource)
		namespace = controller_path.split('/').first
		if namespace.size > 1
			send("#{namespace}_#{function_name}".to_sym, resource)
		else
			send("#{function_name}".to_sym, resource)
		end
	end

	def render_partial(partial_file, params)
		namespace = controller_path.split('/').first
		json.partial! partial: "#{namespace}/#{partial_file}", params
	end

	def render_partial_small(model_name, resource)
		namespace = controller_path.split('/').first
		json.partial! partial: "#{namespace}/#{model_name.to_s.downcase}s/#{model_name.to_s.downcase}_small", :locals => { model_name.to_s.downcase.to_sym => resource }
	end
end