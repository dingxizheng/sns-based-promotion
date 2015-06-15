json.array!(products) do |product|
	
	json.id product.get_id
	
	json.extract! product, :price, :name, :description, :time, :created_at

end
