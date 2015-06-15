# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# user1 = {
# 	name: 'admin',
# 	email: 'arjun@ibm.com',
# 	password: 'root',
# 	phone: '807-631-9942',
# 	address: '16 Morbank drive',
# 	description: 'The data can then be loaded with the rake db:seed',
# 	keywords: ['one', 'two']
# }

# user2 = {
# 	name: 'xding',
# 	email: 'xding@ibm.com',
# 	password: 'root',
# 	phone: '807-631-9945',
# 	address: '8200 warden avenue',
# 	description: 'This file should contain all the record creation needed'
# }

# user3 = {
# 	name: 'arjun',
# 	email: 'dingxizheng@ibm.com',
# 	password: 'root',
# 	phone: '807-631-9949',
# 	address: '8200 warden avenue ,eee',
# 	description: 'This file should contain all the record creation needed'
# }

# User.delete_all


# user = User.new(user1)
# user.add_role :admin
# user.save

# user = User.new(user2)
# user.add_role :customer
# user.save

# user = User.new(user3)
# user.add_role :customer
# user.save

# keywords = ['nike', 'france', 'cheap', 'damn', 'one two', 'china', '678', 'good', 'bad', 'england', 'king']
# # keywords = ['nike', 'france', 'cheap', 'damn', 'one two', 'china', '678', 'good', 'bad', 'england', 'king']
# # 
# addresses = [
# 	'1 Glencove Dr. Markham, On. Canada',
# 	'16 Morbank Dr. Scarborough, On. Canada',
# 	'19 Country Blvd. Tunder Bay, On. Canada',
# 	'3300 Midland Ave Toronto, ON M1V 4A1',
# 	'25 Sheppard Ave W Toronto, ON M2N',
# 	'North Elgin Centre 11005 Yonge St Richmond Hill, ON L4C 0K7'
# ]

# for u in User.all
# 	u.address = addresses[rand(0...6)]
# 	u.save
# end

# require 'json'
# file = File.read('db/data.json')
# users = JSON.parse(file)

# for u in users
# 	add = u['address'] + ', ' + u['city'] + ', ' + u['region'] + ', ' + u['country']
# 	user = {
# 		name: u['name'],
# 		email: u['email'],
# 		phone: u['phone'],
# 		address: add,
# 		description: u['descritpion'],
# 		password: 'root'
# 	}

# 	user_ = User.new(user)
# 	user_.add_role :customer
# 	user_.save
# end


# load 'db/import_catagory.rb' 
# load 'db/import_promotions.rb'
#load 'db/import_products.rb'
load 'db/populate_subscriptions.rb'

