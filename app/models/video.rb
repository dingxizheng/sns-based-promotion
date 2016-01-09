#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-07 16:44:51
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-07 17:14:50

# is used to get video info
require 'streamio-ffmpeg'

class Video
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :file_name, type: String
  field :extension, type: String
  field :size, type: BigDecimal
  field :height, type: BigDecimal
  field :width, type: BigDecimal
  field :cover_url, type: String
  field :thumb_url, type: String
  field :medium_url, type: String

  def store(data_from_request = nil, filecontent = nil)

	# 
  	if not data_from_request.nil? 
      file_name = data_from_request.original_filename  if  (data_from_request != '')    
      file = data_from_request.read
      self.file_name = file_name
    end

    unless filecontent.nil?
      file = filecontent
    end
  end

end
