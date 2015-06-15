
# get all customers
users = []
User.all.each do |user|
	if user.roles.map { |r| r.name }.include? 'customer' and user.subscriptions.count > 0
		puts user.name
		puts user.subscriptions[0].product[:name]
		puts user.subscriptions[0].expire_at
		puts user.subscripted
		puts user.subscriptions[0].save
		# users << user
		# user.subscriptions[0].update_subscription_status
		# puts user.subscriptions[0].when_to_update_subscription_status
		# user.subscriptions[0].delay(run_at: user.subscriptions[0].when_to_update_subscription_status).update_subscription_status
		# user.subscriptions[0].update_subscription_status
	end
end

# get 20 users
# sample_users = users.sample(20)

# a_day = 24 * 60 * 60

# sample_users.each do |user|
# 	subscription = Subscription.new({ :start_at => Time.now + rand(-60..30) * a_day })
# 	subscription.product = Product.all[rand(0..3)].get_hash
# 	subscription.save

# 	puts subscription.product[:name]

# 	user.subscriptions << subscription

# 	puts user.subscriptions.count
# end