json.id subscription.get_id

json.url subscription_url(subscription)

json.extract! subscription, :status, :created_at, :updated_at, :expire_at, :start_at

json.product subscription.product

json.customer do
	json.id subscription.user.get_id
	json.url user_url(subscription.user)
	json.name subscription.user.name
	json.email subscription.user.email
	json.phone subscription.user.phone
	json.address subscription.user.address

	if not subscription.user.logo.nil?
		json.logo do
			json.image_url subscription.user.logo.image_url
			json.thumb_url subscription.user.logo.thumb_url
		end
	end
end