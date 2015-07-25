
# puts ENV['MONGO_USERNAME']


user1 = {
  name: 'dingxizheng',
  email: 'dingxizheng@gmail.com',
  password: 'admin',
  phone: '807-631-9942',
  address: '472 Rupert Str. Thunder Bay, Ontario',
  description: 'The data can then be loaded with the rake db:seed',
  keywords: ['admin']
}

if not User.where({ :email => user1[:email] }).first.present?

  user = User.new(user1)
  user.add_role :admin
  user.save

end
