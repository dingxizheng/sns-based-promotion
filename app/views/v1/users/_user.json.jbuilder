json.id user.get_id

json.url resource_path_to('user_url', user)

json.extract! user, :name, :tags, :created_at, :updated_at

json.comments do
	json.count user.reviews.count
	json.url reviews_url(:customer_id => user.get_id)
end

json.coordinates user.coordinates

json.roles user.roles.pluck :name

if Rails.application.config.request_location.present? and user.has_role? :customer and not user.coordinates.nil? and not user.address.nil?
	json.distance user.distance_to([Rails.application.config.request_location[:lat], Rails.application.config.request_location[:long]]) * 1.60934
end

if not user.logo.nil?
	json.logo do
		json.image_url user.logo.image_url
		json.thumb_url user.logo.thumb_url
	end
end

if not user.background.nil?
	json.background do
		json.image_url user.background.image_url
		json.thumb_url user.background.thumb_url
	end
end