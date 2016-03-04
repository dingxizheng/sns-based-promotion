json.id tag.get_id

json.url resource_path_to('tag_url', tag)

json.extract! tag, :body, :status

json.likes do
	json.count tag.likes
end

json.dislikes do
	json.count tag.dislikes
end

# if tag.tagged_users
# 	json.users do
# 		json.count tag.tagged_users.count
# 		json.url resource_path_to('users_url', { :tags => [tag.body]})
# 	end
# end

# if tag.tagged_promotions
# 	json.promotions do
# 		json.count tag.tagged_promotions.count
# 		json.url resource_path_to('promotions_url', { :tags => [tag.body]})
# 	end
# end

# if not promotion.video.nil?
# 	json.video do 
# 		render_image(json, user.background)
# 	end
# end