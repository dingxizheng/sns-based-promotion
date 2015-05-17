
json.url promotion_url( promotion )
json.id promotion.get_id
json.extract! promotion, :title, :description, :created_at, :updated_at, :expire_at, :start_at

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
	json.address promotion.customer.address
end