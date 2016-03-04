puts "NIMEI: #{activities.count}"

json.array! activities do |activity|

	if activity.trackable.nil?
		next
	elsif activity.owner_type == 'Subscribable'
		json.type activity.trackable_type
		json.result do 
			render_partial json, 'promotions/promotion', { :promotion => activity.trackable }
		end

		json.subscribable do 
			render_partial json, 'subscribables/subscribable', { :subscribable => activity.owner }
		end

	elsif activity.trackable_type == 'Promotion'
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