json.id tag.get_id

json.url resource_path_to('tag_url', tag)

json.extract! tag, :body, :status

json.likes do
	json.count tag.likes
end

json.dislikes do
	json.count tag.dislikes
end

if tag.users
	json.users do
		json.count tag.users.count
		json.url resource_path_to('users_url', { :tags => [tag.body]})
	end
end

if tag.promotions
	json.promotions do
		json.count tag.promotions.count
		json.url resource_path_to('promotions_url', { :tags => [tag.body]})
	end
end

# if not promotion.video.nil?
# 	json.video do 
# 		render_image(json, user.background)
# 	end
# end