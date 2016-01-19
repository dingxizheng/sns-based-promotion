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
	json.avatar do 
		render_user_avatar(json, user)
	end
end

if not user.background.nil?
	json.background do 
		render_image(json, user.background)
	end
end

json.likes do
	json.count user.likes
end

json.dislikes do
	json.count user.dislikes
end