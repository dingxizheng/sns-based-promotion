json.id user.get_id

json.url user_url(user)

json.keywords user.keywords

json.extract! user, :name, :email, :address, :phone, :created_at, :updated_at

json.coordinates user.coordinates

json.roles(user.roles) do |role|
	json.role role.name
end

if not user.logo.nil?
	json.logo do
		json.image_url user.logo.image_url
		json.thumb_url user.logo.thumb_url
	end
end

if user.session and not user.session.expire?
	json.session do
		json.apitoken user.session.access_token
		json.expire_at user.session.expire_at
	end
end