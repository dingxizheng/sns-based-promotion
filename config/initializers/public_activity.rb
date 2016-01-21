#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-01-20 20:05:00
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-01-20 21:17:49

# puts "PublicActivity #{ PublicActivity.methods }"
PublicActivity::Config.set do
  orm :mongoid
end