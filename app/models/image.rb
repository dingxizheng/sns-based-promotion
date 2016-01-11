#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-09 22:43:24
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-10 01:39:31

class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  # image file
  mount_uploader :file, AvatarUploader

  # validate file size
  validate :validate_size

  belongs_to :avatar_owner, inverse_of: :avatar, class_name: 'User'
  belongs_to :backgroud_owner, inverse_of: :background, class_name: 'User'
  belongs_to :photos_owner, inverse_of: :photos, class_name: 'User'

  private 
  def validate_size
  	if file.file.size.to_f/(1000*1000) > Settings.image.size_limit
  		errors.add(:file, I18n.t('errors.validations.image_size') % Settings.image.size_limit)
  	end
  end

end
