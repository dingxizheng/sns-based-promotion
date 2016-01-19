json.id promotion.get_id

json.url resource_path_to('promotion_url', promotion)

json.extract! promotion, :body, :tags, :status

json.likes do
	json.count promotion.likes
end

json.dislikes do
	json.count promotion.dislikes
end

if promotion.user.present?
	json.user do
		render_partial_small(json, :user, promotion.user)
	end
end

# if not promotion.video.nil?
# 	json.video do 
# 		render_image(json, user.background)
# 	end
# end