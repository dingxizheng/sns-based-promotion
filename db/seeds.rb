# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require 'net/http'

doc_data = File.open('/Users/mover/Documents/Media/background/orange_fall-wallpaper-2560x1600.jpg', 'rb').read
require 'base64'

str = Base64.encode64(doc_data)

# puts str

uri = URI('http://ultraimg.com/api/1/upload/?key=3374fa58c672fcaad8dab979f7687397')
res = Net::HTTP.post_form(uri, 'source' => str)

require "json"


data = JSON.parse(res.body)

# puts JSON.parse(res.body)["image"]["extension"]

   puts data["image"]["extension"]
    puts data["image"]["size"]
    puts data["image"]["width"]
    puts data["image"]["height"]
    puts  data["image"]["image"]["url"]
    puts  data["image"]["thumb"]["url"]
    puts data["image"]["medium"]["url"]

