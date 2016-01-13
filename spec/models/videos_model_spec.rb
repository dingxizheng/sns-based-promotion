#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-10 23:49:47
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-11 13:24:35

require "rails_helper"

RSpec.describe Video, :type => :model do
	it "create new video with duration > 17 seconds" do
		video = Video.new
		video.file = File.open(Settings.video.test_file_one.strip)
		video.save!
		# expect(video.save!).to raise_error
		expect(video.duration).to be > 17
	end
end