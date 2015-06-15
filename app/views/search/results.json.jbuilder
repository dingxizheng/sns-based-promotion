json.array! @hits do |hit|
	next if hit[:result].nil?
	json.class hit[:class_name]
	json.result do
		if hit[:class_name] == 'User'
			json.partial!(partial: 'users/user', :locals => { user: hit[:result] })
		elsif hit[:class_name] == 'Promotion'
			json.partial!(partial: 'promotions/promotion', :locals => { promotion: hit[:result] })
		end
	end
end