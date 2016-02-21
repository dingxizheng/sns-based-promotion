json.array! activities do |activity|

	if activity.trackable_type == 'Promotion'
		json.type activity.trackable_type
		json.result do 
			render_partial json, 'promotions/promotion', { :promotion => activity.trackable }
		end
	
	elsif activity.trackable_type == 'Comment'
		json.type activity.trackable_type
		json.result do 
			render_partial json, 'comments/comment', { :comment => activity.trackable }
		end
	
	end
end