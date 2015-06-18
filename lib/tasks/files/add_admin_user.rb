
user1 = {
  name: 'dingxizheng',
  email: 'dingxizheng@gmail.com',
  password: '1990322Kobe',
  phone: '807-631-9942',
  address: '16 Morbank drive',
  description: 'The data can then be loaded with the rake db:seed',
  keywords: ['admin', 'user']
}

if not User.where({ :email => user1[:email] }).first.present?

  user = User.new(user1)
  user.add_role :admin
  user.save

end
