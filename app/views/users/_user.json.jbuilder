json.id user.get_id

json.url user_url(user)

json.keywords user.keywords

json.extract! user, :name, :email, :address, :phone, :description, :created_at, :updated_at

json.subscripted user.subscripted?

json.coordinates user.coordinates

json.roles user.roles.pluck :name

if Rails.application.config.request_location.present?
	json.distance user.distance_from([Rails.application.config.request_location[:lat], Rails.application.config.request_location[:long]]) * 1.60934
end

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