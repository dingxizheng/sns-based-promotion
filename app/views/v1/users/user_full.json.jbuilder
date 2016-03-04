json.id user.get_id

json.url resource_path_to('user_url', user)

json.extract! user, :name, :email, :address, :tags, :phone, :description, :created_at, :updated_at, :comments_count, :promotions_count, :likers_count, :photos_count, :opinions_count

json.comments do
	json.count user.comments.count
	json.url resource_path_to('user_comments_url', user)
end

json.coordinates user.coordinates

json.roles user.get_roles

json.distance resource_distance(user)

json.avatar do
	if not user.get_avatar.nil?
		render_user_avatar(json, user)
	end
end

json.background do 
	if not user.background.nil?
		render_image(json, user.background)
	end
end

json.likes do
	json.count user.likes
end

json.dislikes do
	json.count user.dislikes
end