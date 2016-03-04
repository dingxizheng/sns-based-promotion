json.id promotion.get_id

json.url resource_path_to('promotion_url', promotion)

json.extract! promotion, :body, :tags, :created_at, :updated_at, :start_at, :expire_at, :status, :price

json.comments do
	json.count promotion.comments.count
	json.url resource_path_to('promotion_comments_url', promotion)
end

if current_user.present?
	json.liked current_user.liked?(promotion)
end

json.coordinates promotion.coordinates

json.distance resource_distance(promotion)

json.likes do
	json.count promotion.likes
end

json.dislikes do
	json.count promotion.dislikes
end

json.reposts do
	json.count promotion.reposts_count
end

if promotion.user.present?
	json.user do
		render_partial_small(json, :user, promotion.user)
	end
end

json.photos do
	json.array!(promotion.photos) do |photo|
		render_image(json, photo)
	end
end

if promotion.parent
	json.parent do
		render_partial json, 'promotions/promotion_small', { :promotion => promotion.parent }
	end
end

if promotion.root
	json.root do
		render_partial json, 'promotions/promotion', { :promotion => promotion.root }
	end
end

# if not promotion.video.nil?
# 	json.video do 
# 		render_image(json, user.background)
# 	end
# end