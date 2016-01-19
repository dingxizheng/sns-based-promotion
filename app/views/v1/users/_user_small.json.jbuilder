json.id user.get_id

json.url resource_path_to('user_url', user)

json.name user.name

json.description user.description

if not user.get_avatar.nil?
	json.avatar do 
		render_user_avatar(json, user)
	end
end