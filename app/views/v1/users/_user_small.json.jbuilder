json.id user.get_id

json.url resource_path_to('user_url', user)

json.name user.name

json.tags user.tags

json.description user.description

json.avatar do 
	if not user.get_avatar.nil?
		render_user_avatar(json, user)
	end
end