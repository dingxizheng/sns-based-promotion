#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-18 22:32:23
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-02-20 20:06:17

class GridfsController < ApplicationController

	before_action :restrict_access, only: [:upload_image]

	# POST /images
	def upload_image
		# puts params[:file].read
		@image = current_user.photos.build({:file => params[:file]})
		raise UnprocessableEntityError.new(@image.errors) unless @image.save
		render :json => { image: @image.get_id }, :status => 201
	end

	def image
		img = Image.find(params[:image_id])
		if img.present?
			content = img.file.thumb.read
			send_data content, type: img.file.content_type, disposition: "inline"
		end
	end

	def video
		video = Video.find(params[:video_id])
		if video.present?
			content = video.file.read
			send_data content, type: video.file.content_type, disposition: "inline"
		end
	end

end