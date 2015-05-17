json.array!(catagorys) do |catagory|
	
	json.id catagory.get_id
	json.name catagory.name
	
	if not catagory.icon.nil?
		json.icon do
			json.image_url catagory.icon.image_url
			json.thumb_url catagory.icon.thumb_url
		end
	end

end
