json.id user.get_id

json.url user_url(user)

json.keywords user.keywords

json.extract! user, :name, :email, :address, :phone, :description, :created_at, :updated_at

json.coordinates user.coordinates

json.roles user.roles.pluck :name

if not user.logo.nil?
	json.logo do
		json.image_url user.logo.image_url
		json.thumb_url user.logo.thumb_url
	end
end

json.photos do
	json.array! user.photos do |p|
		json.image_url p.image_url
		json.thumb_url p.thumb_url
	end
end