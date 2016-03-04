#!/usr/bin/ruby
# @Author: dingxizheng
# @Date:   2016-03-02 16:53:04
# @Last Modified by:   dingxizheng
# @Last Modified time: 2016-03-02 18:28:49

require "open-uri"

# p2 = User.last.promotions.build({
# 		body: "Built-in 240mAh battery",
# 		parent_id: Promotion.last.get_id
# 	})

# p2.save



images =[
	"http://beautyboutiquela.com/wp-content/uploads/2015/07/Beauty-e1426485286458.jpg",
	# "https://puridunia.com/wp-content/uploads/2016/02/Eyebrow-Makeup-Sydney-CBD-www.uniqueeyebrowssydney.com_.jpg",
	"http://www.abt-academy.net/newdemo/wp-content/uploads/2014/08/20104820_l.jpg",
	# "https://i.thcdn.co/uploads/media/file/000/002/553/3bWVjQrr.jpg"
]

p1 = User.last.promotions.build({
		body: "Solon Services\n\nHaircut Package with Style, Conditioning, and Optional Partial Highlights at Concepts Salon & Spa",
		tags: ["hair cut", "solon service", "beauty"],
		price: 75,
		address: "2191 Dundas Street East Mississauga, ON L4X 1M3"
	})

p1.save


images_ = []
images.each do |image|
	file_name = Time.now.to_i.to_s
	f1 = File.open('tmpImages/' + file_name + '.jpg', 'wb') do |fo|
	  fo.write open(image).read
	  images_ << File.open('tmpImages/' + file_name + '.jpg')
	  # p1.set_photos File.open('tmpImages/' + file_name + '.jpg')
	end	
end

p1.set_photos images_
