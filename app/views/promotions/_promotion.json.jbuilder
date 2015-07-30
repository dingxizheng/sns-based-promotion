
json.url promotion_url( promotion )
json.id promotion.get_id
json.extract! promotion, :title, :description, :subscripted, :status, :created_at, :updated_at, :expire_at, :start_at

json.rates promotion.rate_count

json.rating promotion.rating || 0

json.comments do
	json.count promotion.reviews.count
	json.url reviews_url(:promotion_id => promotion.get_id)
end

if promotion.is_rejected?
	json.reject_reason promotion.reject_reason
end

if Rails.application.config.request_location.present?
	json.distance promotion.customer.distance_from([Rails.application.config.request_location[:lat], Rails.application.config.request_location[:long]]) * 1.60934
end

json.catagory do
	json.id promotion.catagory.get_id
	json.name promotion.catagory.name
	
	if not promotion.catagory.icon.nil?
		json.icon do
			json.image_url promotion.catagory.icon.image_url
			json.thumb_url promotion.catagory.icon.thumb_url
		end
	end
end

json.customer do
	json.id promotion.customer.get_id
	json.url user_url(promotion.customer)
	json.name promotion.customer.name
	json.email promotion.customer.email
	json.phone promotion.customer.phone
	json.address promotion.customer.address

	if not promotion.customer.logo.nil?
		json.logo do
			json.image_url promotion.customer.logo.image_url
			json.thumb_url promotion.customer.logo.thumb_url
		end
	end

end