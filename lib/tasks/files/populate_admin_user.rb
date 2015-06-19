
admin = {
	name: 'Administrator',
	email: 'dingxizheng@gmail.com',
	password: '1990322Kobe',
	phone: '807-631-9942',
	address: '472 Rupert St. Thunder Bay',
	description: 'admin user'
}

user = User.new(admin)
user.add_role :admin
user.save