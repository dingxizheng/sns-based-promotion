json.id user.get_id

json.url resource_path_to('user_url', user)

json.extract! user, :name, :email, :address, :tags, :phone, :description, :created_at, :updated_at

json.comments do
	json.count user.comments.count
	json.url resource_path_to('user_comments_url', user)
end

json.coordinates user.coordinates

json.roles user.get_roles

json.distance resource_distance(user)

if not user.get_avatar.nil?
	json.avatar json, render_user_avatar(user)
end

if not user.background.nil?
	json.background json, render_image(user.background)
end