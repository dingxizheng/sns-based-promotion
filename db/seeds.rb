# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = {
	name: 'admin',
	email: 'arjun@ibm.com',
	password: 'root',
	phone: '807-631-9942',
	address: '16 Morbank drive'
}

user = User.create(amdin)

user.add_role :admin
