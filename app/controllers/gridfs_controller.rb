#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-18 22:32:23
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-18 23:02:57

class GridfsController < ApplicationController

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