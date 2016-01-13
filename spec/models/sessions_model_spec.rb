#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-12 17:17:18
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-13 00:49:48

require "rails_helper"

RSpec.describe Session, :type => :model do
	it "session token should be encrypted" do
		session = Session.new
		session.provider_access_token = "good"
		# expect(video.save!).to raise_error
		expect(session.provider_access_token).to eq("good")
		expect(session.provider_access_token_encrypted).not_to eq("good")
	end
end