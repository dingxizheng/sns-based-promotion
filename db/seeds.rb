# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user1 = {
	name: 'admin',
	email: 'arjun@ibm.com',
	password: 'root',
	phone: '807-631-9942',
	address: '16 Morbank drive',
	description: 'The data can then be loaded with the rake db:seed',
	keywords: ['one', 'two']
}

user2 = {
	name: 'xding',
	email: 'xding@ibm.com',
	password: 'root',
	phone: '807-631-9945',
	address: '8200 warden avenue',
	description: 'This file should contain all the record creation needed'
}

user3 = {
	name: 'arjun',
	email: 'dingxizheng@ibm.com',
	password: 'root',
	phone: '807-631-9949',
	address: '8200 warden avenue ,eee',
	description: 'This file should contain all the record creation needed'
}

User.delete_all


user = User.new(user1)
user.add_role :admin
user.save

user = User.new(user2)
user.add_role :customer
user.save

user = User.new(user3)
user.add_role :customer
user.save