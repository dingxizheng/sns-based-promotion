#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-03-02 16:53:04
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-03-02 18:59:51

require "open-uri"

# p2 = User.last.promotions.build({
# 		body: "Built-in 240mAh battery",
# 		parent_id: Promotion.last.get_id
# 	})

# p2.save



images =[
	"http://www.logodesignlove.com/images/negative/wwf-logo-design.jpg"
]

# u1 = User.new({
# 		name: 'Roncesvalles Village',
# 		description: 'The Revue has occupied its Roncesvalles Avenue location since 1912 and is one of the oldest continuously running movie theaters in the country',
# 		tags: ["Date Night", "Movie Buff", "Rainy Day"],
# 		email: "test2@gmail.com",
# 		password: '123456',
# 		address: "2191 Dundas Street East Mississauga, ON L4X 1M3"
# 	})

# u1.save


images_ = []
images.each do |image|
	file_name = Time.now.to_i.to_s
	f1 = File.open('tmpImages/' + file_name + '.jpg', 'wb') do |fo|
	  fo.write open(image).read
	  images_ << File.open('tmpImages/' + file_name + '.jpg')
	  # p1.set_photos File.open('tmpImages/' + file_name + '.jpg')
	end	
end

User.find_by({ email: "react@native.com" }).set_avatar images_[0]
