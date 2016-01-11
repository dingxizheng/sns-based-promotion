#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-07 16:44:51
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-11 11:23:45

# is used to get video info
require 'streamio-ffmpeg'

class Video
  include Mongoid::Document
  include Mongoid::Timestamps

  field :duration, type: BigDecimal
  field :size, type: BigDecimal
  field :width, type: Integer
  field :height, type: Integer
  field :video_codec, type: String
  field :video_stream, type: String
  field :video_rate, type: Float
  field :audio_stream , type: String
  field :audio_codec, type: String
  field :audio_channels, type: String

  mount_uploader :file, AdsVideoUploader

  validate :validates_video_content

  private
  # def validates_video
  # 	if self.file.file.size.to_f/(1000*1000) > Settings.video.size_limit
  # 		errors.add(:file, I18n.t('errors.validations.video_size') % Settings.video.size_limit)
  # 	end
  # end

  def validates_video_content
  	# read video info
  	video = FFMPEG::Movie.new(Settings.video.test_file_one.strip)
  	
  	# validates video size
  	if video.size.to_f / (1000 * 1000) > Settings.video.size_limit
  		errors.add(:size, I18n.t('errors.validations.video_size') % Settings.video.size_limit )
  	end

  	# validates video width
  	if video.width > Settings.video.max_width or
  		video.width < Settings.video.min_width or
  		errors.add(:width, I18n.t('errors.validations.video_width') % [Settings.video.min_width, Settings.video.max_width])
  	end
  	
  	# validates video height
  	if video.height > Settings.video.max_height or
  		video.height < Settings.video.min_height
  		errors.add(:height, I18n.t('errors.validations.video_height') % [Settings.video.min_height, Settings.video.max_height])
  	end

  	# validates video duration
  	if video.duration > Settings.video.duration_limit
  		errors.add(:duration, I18n.t('errors.validations.video_duration') % Settings.video.duration)
  	end

  end

end
