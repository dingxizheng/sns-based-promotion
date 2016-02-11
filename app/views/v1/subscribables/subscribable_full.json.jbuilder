json.id subscribable.get_id

json.url resource_path_to('subscribable_url', subscribable)

json.extract! subscribable, :name, :description, :tags, :maximum_price, :minimum_price, :created_at, :updated_at

json.likes do
	json.count subscribable.likes
end

json.dislikes do
	json.count subscribable.dislikes
end

if subscribable.user.present?
	json.user do
		render_partial_small(json, :user, subscribable.user)
	end
end