
json.url promotion_url( promotion )
json.id promotion.get_id
json.extract! promotion, :created_at, :updated_at, :expire_at

json.customer do
	json.id promotion.customer.get_id
	json.url user_url(promotion.customer)
	json.name promotion.customer.name
	json.email promotion.customer.email
	json.address promotion.customer.address
end